export GNUMAKEFLAGS := --no-print-directory

ifeq ($(DEBUG),Y)
CMAKE_FLAGS := -DCMAKE_BUILD_TYPE=Debug
BUILD_DIR := debug
else
BUILD_DIR := release
endif

.PHONY: all
all: build/$(BUILD_DIR)/Makefile
	@+cmake --build build/$(BUILD_DIR)

build/$(BUILD_DIR)/Makefile:
	@+cmake $(CMAKE_FLAGS) -B build/$(BUILD_DIR) .

.PHONY: clean
clean:
	@rm -rf build

%:
	@+cmake --build build/$(BUILD_DIR) --target $@
