#!/usr/bin/env bash
# Runs one hello-world sample app the way its README tells readers to, then
# checks that:
#   1. the app prints the document shown in the README's expected output
#   2. the app exits non-zero with a clear message when MONGODB_URI is unset
#   3. the app exits non-zero with a clear message when MONGODB_URI is blank
#
# Results print to the console. In GitHub Actions (or act), they are also
# written as a table to the run's summary page.
#
# The app's code is never imported or modified; the test only runs the
# commands from the README and inspects exit codes and output.
#
# Usage: MONGODB_URI=<uri> tests/test-app.sh <language>
# C and C++ also require VCPKG_ROOT (the vcpkg checkout used to resolve the
# project's vcpkg.json manifest).
# Requires: jq
set -uo pipefail

LANGUAGE="${1:?usage: tests/test-app.sh <language>}"
: "${MONGODB_URI:?Set MONGODB_URI to a MongoDB deployment the test can write to.}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$REPO_ROOT/$LANGUAGE/hello-world"
cd "$APP_DIR" || { echo "FAIL: no app at $APP_DIR"; exit 1; }

# Install and run commands for each language, copied from its README.
case "$LANGUAGE" in
  c|cpp)
    : "${VCPKG_ROOT:?Set VCPKG_ROOT to a vcpkg checkout to test $LANGUAGE.}"
    # The project's vcpkg.json manifest pins the driver version. Passing
    # the vcpkg toolchain file is what tells CMake to resolve it, the same
    # step the README's Linux/Windows instructions use.
    install() {
      cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
      cmake --build build
    }
    run() { ./build/hello-world; }
    ;;
  go)
    install() { go mod download; }
    run() { go run .; }
    ;;
  ruby)
    install() { bundle install; }
    run() { bundle exec ruby hello_world.rb; }
    ;;
  java|java-rs|kotlin-sync|kotlin-coroutine)
    install() { mvn compile; }
    run() { mvn compile exec:java; }
    ;;
  scala)
    # The README has no separate install step; `sbt run` resolves
    # dependencies itself. Compile first so a dependency or build failure
    # is reported as an install failure.
    install() { sbt compile; }
    run() { sbt run; }
    ;;
  dotnet)
    install() { dotnet restore; }
    run() { dotnet run; }
    ;;
  rust)
    install() { cargo build; }
    run() { cargo run; }
    ;;
  node)
    install() { npm install; }
    run() { node index.js; }
    ;;
  python)
    install() { python3 -m venv venv && source venv/bin/activate && python3 -m pip install -r requirements.txt; }
    run() { source venv/bin/activate && python3 main.py; }
    ;;
  php)
    # The README installs the mongodb extension with PIE before this step.
    # In CI, the workflow does that; locally, install it first.
    install() { composer install; }
    run() { php src/HelloWorld.php; }
    ;;
  *)
    echo "FAIL: no commands defined for '$LANGUAGE' in tests/test-app.sh"
    exit 1
    ;;
esac

# Color PASS/FAIL only when printing to a terminal, so CI logs stay plain.
if [ -t 1 ]; then GREEN=$'\e[32m'; RED=$'\e[31m'; RESET=$'\e[0m'; else GREEN=""; RED=""; RESET=""; fi

failures=0
summary_rows=""
summary_details=""

# Records a check result for the console and for the CI summary table.
# Usage: record pass|fail "<check name>" ["<detail text>"]
record() {
  local status="$1" name="$2" detail="${3:-}"
  if [ "$status" = pass ]; then
    echo "${GREEN}PASS${RESET}: $name"
    summary_rows+="| ✅ | $name |"$'\n'
  else
    echo "${RED}FAIL${RESET}: $name"
    failures=$((failures + 1))
    summary_rows+="| ❌ | $name |"$'\n'
    if [ -n "$detail" ]; then
      sed 's/^/  | /' <<<"$detail"
      summary_details+=$'\n'"<details><summary>$name</summary>"$'\n\n```\n'"$detail"$'\n```\n</details>\n'
    fi
  fi
}

# Writes this language's results to the GitHub Actions run summary page.
# Skipped when not running in GitHub Actions or act.
write_summary() {
  [ -n "${GITHUB_STEP_SUMMARY:-}" ] || return 0
  local status="✅ All checks passed"
  [ "$failures" -gt 0 ] && status="❌ $failures check(s) failed"
  {
    echo "## $LANGUAGE: $status"
    echo
    echo "| Result | Check |"
    echo "|---|---|"
    printf '%s' "$summary_rows"
    printf '%s' "$summary_details"
    echo
  } >> "$GITHUB_STEP_SUMMARY"
}

finish() {
  echo "== $LANGUAGE: $failures failure(s)"
  write_summary
  [ "$failures" -eq 0 ] && exit 0
  exit 1
}

echo "== $LANGUAGE: install"
if ! install_out=$(install 2>&1); then
  record fail "install dependencies" "$install_out"
  finish
fi
record pass "install dependencies"

# The expected document is the "Wireless Mouse" line inside a fenced code
# block in the README, so the README stays the single source of truth.
expected=$(awk '/^```/{inblock=!inblock; next} inblock && /"Wireless Mouse"/' README.md)
if [ -z "$expected" ]; then
  record fail "read expected output from README" "No \"Wireless Mouse\" line found in a code block in README.md"
  finish
fi

echo "== $LANGUAGE: run with MONGODB_URI set"
if actual=$(run 2>&1); then
  # Compare as JSON, not text: drivers differ in whitespace, and _id is a
  # new ObjectId on every run, so check only that it is an $oid.
  normalize='if (._id | type) == "object" and (._id | has("$oid")) then del(._id) else error("_id is not an $oid") end'
  # Build tools such as Maven print their own logs around the app's output,
  # so pick out the app's JSON line rather than assuming it is the last line.
  act_line=$(grep '"Wireless Mouse"' <<<"$actual" | tail -n 1)
  # Both sides must normalize successfully before they are compared.
  # Otherwise two identical jq error messages would count as a match.
  if ! exp_doc=$(jq -cS "$normalize" <<<"$expected" 2>&1); then
    record fail "output matches README" "Could not read the README's expected output as a document with an \$oid _id:"$'\n'"$exp_doc"
  elif [ -z "$act_line" ]; then
    record fail "output matches README" "No line containing \"Wireless Mouse\" in the app's output:"$'\n'"$actual"
  elif ! act_doc=$(jq -cS "$normalize" <<<"$act_line" 2>&1); then
    record fail "output matches README" "Could not read the app's output as a document with an \$oid _id:"$'\n'"$act_line"$'\n'"$act_doc"
  elif [ "$exp_doc" = "$act_doc" ]; then
    record pass "output matches README"
  else
    record fail "output matches README" "expected: $exp_doc"$'\n'"actual:   $act_doc"
  fi
else
  record fail "output matches README" "App exited non-zero with MONGODB_URI set:"$'\n'"$actual"
fi

check_rejects_uri() {
  local label="$1"; shift
  local name="MONGODB_URI $label: exits non-zero with setup message"
  echo "== $LANGUAGE: run with MONGODB_URI $label"
  local out
  if out=$("$@" 2>&1); then
    record fail "$name" "App exited 0. Output:"$'\n'"$out"
  elif grep -q "Set the MONGODB_URI environment variable" <<<"$out"; then
    record pass "$name"
  else
    record fail "$name" "App exited non-zero, but without the setup message. Output:"$'\n'"$out"
  fi
}
check_rejects_uri "unset" env -u MONGODB_URI bash -c "$(declare -f run); run"
check_rejects_uri "blank" env MONGODB_URI="   " bash -c "$(declare -f run); run"

finish
