cmake_minimum_required(VERSION 3.12)

# initialize pico_sdk from submodule
# note: this must happen before project()
include(lib/pico-sdk/pico_sdk_init.cmake)

add_subdirectory(lib/pico-tiny)

project(target)

# initialize the Pico SDK
pico_sdk_init()

include_directories(
  src
)

set(target_SRC
  src/main.c
)

add_executable(target ${target_SRC})

target_compile_options(target PUBLIC -Wall -Wextra -Werror)

target_link_libraries(target pico_tiny)

# create map/bin/hex/uf2 file in addition to ELF.
pico_add_extra_outputs(target)
