
all:disk

boot.bin: enter_pm.asm
	nasm  enter_pm.asm -o boot.bin -l boot.lst


disk: boot.bin
	dd if=boot.bin of=c.img bs=512 count=1 conv=notrunc
clean:
	rm -f *.lst *.bin