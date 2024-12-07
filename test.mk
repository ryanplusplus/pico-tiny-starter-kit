TARGET := tests
BUILD_DIR := ./build/test

INC_DIRS := \
  lib/pico-tiny/lib/tiny/include \
  lib/pico-tiny/lib/tiny/test/include \
  include \
  src \

SRC_DIRS := \
  lib/pico-tiny/lib/tiny/src \
  lib/pico-tiny/lib/tiny/test/src \
  src/dummy \
  test \
  test/dummy \

SRC_FILES := \
  lib/pico-tiny/lib/tiny/test/tests/test_runner.cpp \

include lib/pico-tiny/lib/tiny/Makefile
