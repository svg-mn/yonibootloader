# -*- Makefile -*-

ASM:=nasm

SRC_DIR:=src/bootloader
BUILD_DIR:=build
BOOT_FILE:=boot

# Define phony targets
.PHONY: clean, run, all

all: $(BUILD_DIR)/disk.img
########
# The main target to build the disk image
########

# The hirarchy is from th last file we need (disk.img) to the first (boot.asm)
$(BUILD_DIR)/disk.img: $(BUILD_DIR)/boot.bin
######## 
#Build the disk image from the bootloader and kernel 
########
	dd if=/dev/zero of=$(BUILD_DIR)/disk.img bs=512 count=2880
	dd if=$(BUILD_DIR)/boot.bin of=$(BUILD_DIR)/disk.img bs=512 count=1 conv=notrunc
	dd if=$(BUILD_DIR)/kernel.bin of=$(BUILD_DIR)/disk.img bs=512 seek=1 conv=notrunc

$(BUILD_DIR)/boot.bin: $(SRC_DIR)/$(BOOT_FILE).asm
########
# Assemble the bootloader source file to create an object file
########
	$(ASM) $(SRC_DIR)/$(BOOT_FILE).asm -f bin -o $(BUILD_DIR)/boot.bin

clean:
########
# Clean up build files
########
	rm -f $(BUILD_DIR)/*

run:
########
# Run the disk image in QEMU
########
	qemu-system-x86_64 -drive format=raw,file=build/disk.img -d int --no-reboot
