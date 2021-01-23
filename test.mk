TARGET := tests
BUILD_DIR := ./build/test

INC_DIRS := \
  lib/tiny/include \
  include \
  src \

SRC_DIRS := \
  lib/tiny/src \
  lib/tiny/test/double \
  src/dummy \
  test \

SRC_FILES := \
  lib/tiny/test/test_runner.cpp \

include lib/tiny/Makefile
