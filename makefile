SVD := lib/pico-sdk/src/rp2040/hardware_regs/rp2040.svd
DEBUG_CFG := tools/debug.cfg
PICO_PLATFORM := rp2040
PICO_BOARD := pico
PICO_COMPILER := pico_arm_gcc

CMAKE_FLAGS := \
  -DPICO_PLATFORM=$(PICO_PLATFORM) \
  -DPICO_BOARD=$(PICO_BOARD) \
  -DPICO_COMPILER=$(PICO_COMPILER) \

ifeq ($(DEBUG),Y)
CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=Debug
BUILD_TYPE := debug
else
CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=Release
BUILD_TYPE := release
endif

export GNUMAKEFLAGS := --no-print-directory

.PHONY: all
all: build/$(BUILD_TYPE)/Makefile
	@+cmake --build build/$(BUILD_TYPE)

build/$(BUILD_TYPE)/Makefile: $(MAKEFILE_LIST)
	@+cmake $(CMAKE_FLAGS) -B build/$(BUILD_TYPE) .

.PHONY: clean
clean:
	@rm -rf build

%:
	@+cmake --build build/$(BUILD_TYPE) --target $@

.PHONY: upload
upload: all
	tools/openocd/build/bin/openocd -f tools/upload-$(BUILD_TYPE).cfg

.PHONY: erase
erase:
	tools/openocd/build/bin/openocd -f tools/erase.cfg

.PHONY: debug-deps
debug-deps: tools/openocd/build/bin/openocd all
	cp $(SVD) build/$(BUILD_TYPE)/target.svd
	cp $(DEBUG_CFG) build/$(BUILD_TYPE)/target.cfg

.PHONY: test
test:
	@$(MAKE) --no-print-directory -f test.mk

tools/openocd/build/bin/openocd:
	@git clone https://github.com/raspberrypi/openocd.git --recursive --branch rp2040 --depth=1 tools/openocd
	@(cd tools/openocd; ./bootstrap && ./configure --prefix=`pwd`/build && $(MAKE) && $(MAKE) install)
