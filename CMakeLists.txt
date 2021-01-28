cmake_minimum_required(VERSION 3.12)

# initialize pico_sdk from submodule
# note: this must happen before project()
include(lib/pico-sdk/pico_sdk_init.cmake)

project(rpi_pico)

# initialize the Pico SDK
pico_sdk_init()

include_directories(
  lib/tiny/include
  src
)

set(target_SRC
  lib/tiny/src/tiny_list.c
  lib/tiny/src/tiny_timer.c
  src/main.c
  src/tiny_i2c.c
  src/tiny_spi.c
  src/tiny_time_source.c
)

add_executable(target ${target_SRC})

# Add pico_stdlib library which aggregates commonly used features
target_link_libraries(target
  pico_stdlib
  hardware_i2c
  hardware_spi
)

# create map/bin/hex/uf2 file in addition to ELF.
pico_add_extra_outputs(target)
