ASM=nasm

SRC_DIR=src/bootloader
BUILD_DIR=build
BOOT_FILE=boot

$(BUILD_DIR)/main_floppy.img: $(BUILD_DIR)/main.bin
	cp $(BUILD_DIR)/main.bin $(BUILD_DIR)/main_floppy.img
	truncate -s 1440k $(BUILD_DIR)/main_floppy.img
	
$(BUILD_DIR)/main.bin: $(SRC_DIR)/$(BOOT_FILE).asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(SRC_DIR)/$(BOOT_FILE).asm -f bin -o $(BUILD_DIR)/main.bin
