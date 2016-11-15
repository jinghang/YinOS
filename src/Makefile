
all:disk

boot.bin: boot/boot.asm
	nasm boot/boot.asm -o boot/boot.bin -l boot/boot.lst

disk: boot.bin
	dd if=boot/boot.bin of=../test/c.img bs=512 count=1 conv=notrunc

clean:
	rm -f boot/*.lst boot/*.bin