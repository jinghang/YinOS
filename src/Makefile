
all:disk

boot.bin: boot/boot.asm
	nasm boot/boot.asm -o boot/boot.bin -l boot/boot.lst

loader.bin: boot/loader.asm
	nasm boot/loader.asm -o boot/loader.bin -l boot/loader.lst

disk: boot.bin loader.bin
	dd if=boot/boot.bin of=../test/c.img bs=512 count=1 conv=notrunc
	dd if=boot/loader.bin of=../test/c.img bs=512 count=1 conv=notrunc seek=1

clean:
	rm -f boot/*.lst boot/*.bin