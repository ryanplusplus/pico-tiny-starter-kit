SVD := lib/pico-sdk/src/rp2040/hardware_regs/rp2040.svd
DEBUG_CFG := tools/debug.cfg
PICO_PLATFORM := rp2040
PICO_BOARD := seeed_xiao_rp2040
PICO_COMPILER := pico_arm_gcc

CMAKE_FLAGS := \
  -DPICO_PLATFORM=$(PICO_PLATFORM) \
  -DPICO_BOARD=$(PICO_BOARD) \
  -DPICO_COMPILER=$(PICO_COMPILER) \
  -DCMAKE_C_COMPILER=$(shell which arm-none-eabi-gcc) \
  -DCMAKE_CXX_COMPILER=$(shell which arm-none-eabi-g++) \
  -DPICO_BOARD_HEADER_DIRS=$(shell pwd)/board \

ifeq ($(RELEASE),Y)
CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=Release
BUILD_TYPE := release
else
CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=Debug
BUILD_TYPE := debug
endif

BUILD_DIR := build/$(BUILD_TYPE)

export GNUMAKEFLAGS := --no-print-directory

.PHONY: all
all: $(BUILD_DIR)/Makefile
	@+cmake --build $(BUILD_DIR)

$(BUILD_DIR)/Makefile: $(MAKEFILE_LIST)
	@+cmake $(CMAKE_FLAGS) -B $(BUILD_DIR) .

.PHONY: clean
clean:
	@rm -rf build

%:
	@+cmake --build $(BUILD_DIR) --target $@

.PHONY: suppress-jlink-edu-popup
suppress-jlink-edu-popup:
	@type lua > /dev/null 2>&1 && lua script/suppress-jlink-edu-popup.lua > /dev/null 2>&1 || true

.PHONY: jlink-upload
jlink-upload: $(BUILD_DIR)/upload.jlink all suppress-jlink-edu-popup
	@JLinkExe -NoGui 1 -device RP2040_M0_0 -if SWD -autoconnect 1 -speed 4000 -CommandFile $<

.PHONY: $(BUILD_DIR)/upload.jlink
$(BUILD_DIR)/upload.jlink:
	@mkdir -p $(dir $@)
	@echo r > $@
	@echo h >> $@
	@echo loadfile $(BUILD_DIR)/target.hex >> $@
	@echo r >> $@
	@echo exit >> $@

.PHONY: jlink-erase
jlink-erase: $(BUILD_DIR)/erase.jlink suppress-jlink-edu-popup
	@JLinkExe -NoGui 1 -device RP2040_M0_0 -if SWD -autoconnect 1 -speed 4000 -CommandFile $<

.PHONY: $(BUILD_DIR)/erase.jlink
$(BUILD_DIR)/erase.jlink:
	@mkdir -p $(dir $@)
	@echo r > $@
	@echo h >> $@
	@echo erase >> $@
	@echo exit >> $@

.PHONY: jlink-debug-deps
jlink-debug-deps: all suppress-jlink-edu-popup
	@cp $(SVD) $(BUILD_DIR)/target.svd

.PHONY: uf2-upload
uf2-upload: all
	@cp $(BUILD_DIR)/target.uf2 /media/ryan/RPI-RP2/

.PHONY: test
test:
	@$(MAKE) --no-print-directory -f test.mk
