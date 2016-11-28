CFLAGS = -Wall -pedantic -W -nostdlib -nostdinc -Wno-long-long -fomit-frame-pointer
all:disk

boot.bin: boot/boot.asm
	nasm boot/boot.asm -o boot/boot.bin -l boot/boot.lst

loader.bin: boot/loader.asm
	nasm boot/loader.asm -o boot/loader.bin -l boot/loader.lst

kernel.o: kernel/kernel.asm
	nasm -f elf -o kernel/kernel.o kernel/kernel.asm

init.o: kernel/init.c
	gcc $(CFLAGS) -Os -c -fno-builtin -m32 -o kernel/init.o kernel/init.c

kernel.bin: kernel.o init.o
	ld --oformat binary -N -e start -Ttext 0x100500 -m elf_i386 -o kernel/kernel.bin kernel/kernel.o kernel/init.o
	

disk: boot.bin loader.bin kernel.bin
	dd if=boot/boot.bin of=../test/c.img bs=512 count=1 conv=notrunc
	dd if=boot/loader.bin of=../test/c.img bs=512 count=1 conv=notrunc seek=1
	dd if=kernel/kernel.bin of=../test/c.img bs=512 count=1 conv=notrunc seek=2

clean:
	rm -f boot/*.lst boot/*.bin kernel/*.o kernel/*.bin