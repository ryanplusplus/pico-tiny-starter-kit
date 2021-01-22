cmake_minimum_required(VERSION 3.12)

# initialize pico_sdk from submodule
# note: this must happen before project()
include(lib/pico-sdk/pico_sdk_init.cmake)

project(tiny)

# initialize the Pico SDK
pico_sdk_init()

add_executable(target
  src/main.c
)

# Add pico_stdlib library which aggregates commonly used features
target_link_libraries(target pico_stdlib)

# create map/bin/hex/uf2 file in addition to ELF.
pico_add_extra_outputs(target)
