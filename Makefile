# -*- Makefile -*-

ASM:=nasm

SRC_DIR:=src/bootloader
BUILD_DIR:=build
BOOT_FILE:=boot

# Define phony targets
.PHONY: clean

# The hirarchy is from th last file we need (disk.img) to the first (boot.asm)
$(BUILD_DIR)/disk.img: $(BUILD_DIR)/boot.bin # $(BUILD_DIR)/kernel.bin
######## 
#Build the disk image from the bootloader and kernel 
########
	dd if=/dev/zero of=$(BUILD_DIR)/disk.img bs=512 count=2880
	dd if=$(BUILD_DIR)/boot.bin of=$(BUILD_DIR)/disk.img bs=512 count=1 conv=notrunc
	dd if=$(BUILD_DIR)/kernel.bin of=$(BUILD_DIR)/disk.img bs=512 seek=1 conv=notrunc

$(BUILD_DIR)/boot.bin: $(BUILD_DIR)/boot.o
########
# Link the bootloader object file to create a binary boot sector
########	
	ld -m elf_i386 -T linker.ld --oformat binary $(BUILD_DIR)/boot.o -o $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/boot.o: $(SRC_DIR)/$(BOOT_FILE).asm
########
# Assemble the bootloader source file to create an object file
########
	$(ASM) $(SRC_DIR)/$(BOOT_FILE).asm -f elf32 -o $(BUILD_DIR)/boot.o

clean:
########
# Clean up build dependencies
########
	rm -f $(BUILD_DIR)/*.bin