From the root directory: 

To compile the bootloader run `make`

To insert the os into the second segment of the disk, run `dd if=build/kernel.bin of=build/main_floppy.img bs=512 seek=1 count=1 conv=notrunc`

To start the bootloader run `qemu-system-x86_64 -hda build/main_floppy.img`

make
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c src/kernel/paging.c -o build/paging.o  -fno-pic
ld -m elf_i386 -T linker.ld -o build/kernel.elf build/paging.o
objcopy -O binary build/kernel.elf build/kernel.bin
dd if=build/kernel.bin of=build/main_floppy.img bs=512 seek=1 count=1 conv=notrunc
qemu-system-x86_64 -hda build/main_floppy.img -d int --no-reboot