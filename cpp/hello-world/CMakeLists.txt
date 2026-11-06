cmake_minimum_required(VERSION 3.15)

project(hello-world CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(mongocxx 4.4 REQUIRED)

add_executable(hello-world main.cpp)

# Homebrew, and vcpkg on Windows, build the driver as a shared library.
# vcpkg on Linux builds it as a static library instead. Link whichever
# one the installed driver provides.
target_link_libraries(hello-world PRIVATE
    $<IF:$<TARGET_EXISTS:mongo::mongocxx_static>,mongo::mongocxx_static,mongo::mongocxx_shared>)
