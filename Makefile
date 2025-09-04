PICO_PLATFORM := rp2350
PICO_BOARD := seeed_xiao_rp2350
PICO_COPY_TO_RAM := 0

MCU := $(shell echo $(PICO_PLATFORM) | cut -c 1-6)
MCU_UPPERCASE := $(shell echo $(MCU) | tr a-z A-Z)
SVD := lib/pico-sdk/src/$(MCU)/hardware_regs/$(MCU_UPPERCASE).svd
JLINK_DEVICE := $(MCU_UPPERCASE)_M0_0

ifeq ($(findstring riscv,$(PICO_PLATFORM)),riscv)
ARCH := riscv
else
ARCH := arm
endif

ifeq ($(ARCH),riscv)
SIZE := riscv32-unknown-elf-size
else
SIZE := arm-none-eabi-size
endif

ifeq ($(RELEASE),Y)
CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=Release
BUILD_TYPE := release
else
CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=Debug
BUILD_TYPE := debug
endif

BUILD_DIR := build/$(BUILD_TYPE)

export GNUMAKEFLAGS := --no-print-directory

CMAKE_FLAGS := \
  -DPICO_PLATFORM=$(PICO_PLATFORM) \
  -DPICO_BOARD=$(PICO_BOARD) \
  -DPICO_COPY_TO_RAM=$(PICO_COPY_TO_RAM) \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -G="Unix Makefiles" \

# Without this flag, pico SDK v2.0.0 does not generate a .hex file
CMAKE_FLAGS += \
  -DPICO_32BIT=1 \

.PHONY: all
all: $(BUILD_DIR)/Makefile
	@+cmake --build $(BUILD_DIR)
	@cp $(BUILD_DIR)/compile_commands.json build/compile_commands.json
	@$(SIZE) $(BUILD_DIR)/target.elf

$(BUILD_DIR)/Makefile: $(MAKEFILE_LIST)
	@+cmake $(CMAKE_FLAGS) -B $(BUILD_DIR) .

.PHONY: clean
clean:
	@rm -rf build

%:
	@+cmake --build $(BUILD_DIR) --target $@

.PHONY: svd
svd:
	@cp $(SVD) $(BUILD_DIR)/target.svd

.PHONY: suppress-jlink-edu-popup
suppress-jlink-edu-popup:
	@type lua > /dev/null 2>&1 && lua script/suppress-jlink-edu-popup.lua > /dev/null 2>&1 || true

.PHONY: jlink-upload
jlink-upload: $(BUILD_DIR)/upload.jlink all suppress-jlink-edu-popup
	@JLinkExe -NoGui 1 -device $(JLINK_DEVICE) -if SWD -autoconnect 1 -speed 4000 -CommandFile $<

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
	@JLinkExe -NoGui 1 -device $(JLINK_DEVICE) -if SWD -autoconnect 1 -speed 4000 -CommandFile $<

.PHONY: $(BUILD_DIR)/erase.jlink
$(BUILD_DIR)/erase.jlink:
	@mkdir -p $(dir $@)
	@echo r > $@
	@echo h >> $@
	@echo erase >> $@
	@echo exit >> $@

.PHONY: jlink-debug-deps
jlink-debug-deps: all suppress-jlink-edu-popup svd

.PHONY: $(BUILD_DIR)/upload.openocd
$(BUILD_DIR)/upload.openocd:
	@mkdir -p $(dir $@)
	@echo source [find interface/cmsis-dap.cfg] > $@
	@echo transport select swd >> $@
	@echo adapter speed 4000 >> $@
	@echo source [find target/$(MCU).cfg] >> $@
	@echo program $(BUILD_DIR)/target.hex verify reset exit >> $@

.PHONY: openocd-upload
openocd-upload: tools/openocd/build/bin/openocd all $(BUILD_DIR)/upload.openocd
	@$< -f $(BUILD_DIR)/upload.openocd

.PHONY: $(BUILD_DIR)/debug.openocd
$(BUILD_DIR)/debug.openocd:
	@mkdir -p $(dir $@)
	@echo source [find interface/cmsis-dap.cfg] > $@
	@echo transport select swd >> $@
	@echo adapter speed 4000 >> $@
	@echo source [find target/$(MCU).cfg] >> $@
	@echo init >> $@
	@echo reset halt >> $@

.PHONY: openocd-debug-deps
openocd-debug-deps: all tools/openocd/build/bin/openocd svd $(BUILD_DIR)/debug.openocd

tools/openocd/build/bin/openocd:
	@rm -rf tools/openocd
	@git clone https://github.com/raspberrypi/openocd.git --recursive --depth=1 tools/openocd
	@(cd tools/openocd; ./bootstrap && ./configure --prefix=`pwd`/build && $(MAKE) && $(MAKE) install)

.PHONY: uf2-upload
uf2-upload: all
	@cp $(BUILD_DIR)/target.uf2 /media/ryan/RPI-RP2/

.PHONY: test
test:
	@$(MAKE) --no-print-directory -f test.mk
