SVD := lib/pico-sdk/src/rp2040/hardware_regs/rp2040.svd
DEBUG_CFG := tools/debug.cfg
PICO_PLATFORM := rp2040
PICO_BOARD := pico
PICO_COMPILER := pico_arm_gcc

CMAKE_FLAGS := \
  -DPICO_PLATFORM=$(PICO_PLATFORM) \
  -DPICO_BOARD=$(PICO_BOARD) \
  -DPICO_COMPILER=$(PICO_COMPILER) \
  -DCMAKE_C_COMPILER=$(shell which arm-none-eabi-gcc) \
  -DCMAKE_CXX_COMPILER=$(shell which arm-none-eabi-g++) \

ifeq ($(RELEASE),Y)
CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=Release
BUILD_TYPE := release
else
CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=Debug
BUILD_TYPE := debug
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

.PHONY: suppress-jlink-edu-popup
suppress-jlink-edu-popup:
	@type lua > /dev/null 2>&1 && lua script/suppress-jlink-edu-popup.lua > /dev/null 2>&1 || true

.PHONY: upload
upload: build/$(BUILD_TYPE)/upload.jlink all suppress-jlink-edu-popup
	@JLinkExe -device RP2040_M0_0 -if SWD -autoconnect 1 -speed 4000 -CommandFile $<

.PHONY: build/$(BUILD_TYPE)/upload.jlink
build/$(BUILD_TYPE)/upload.jlink:
	@mkdir -p $(dir $@)
	@echo r > $@
	@echo h >> $@
	@echo loadfile build/$(BUILD_TYPE)/target.hex >> $@
	@echo r >> $@
	@echo exit >> $@

.PHONY: erase
erase: build/$(BUILD_TYPE)/erase.jlink suppress-jlink-edu-popup
	@JLinkExe -device RP2040_M0_0 -if SWD -autoconnect 1 -speed 4000 -CommandFile $<

.PHONY: build/$(BUILD_TYPE)/erase.jlink
build/$(BUILD_TYPE)/erase.jlink:
	@mkdir -p $(dir $@)
	@echo r > $@
	@echo h >> $@
	@echo erase >> $@
	@echo exit >> $@

.PHONY: debug-deps
debug-deps: all suppress-jlink-edu-popup
	@cp $(SVD) build/$(BUILD_TYPE)/target.svd

.PHONY: test
test:
	@$(MAKE) --no-print-directory -f test.mk
