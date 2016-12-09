#Makefile

ENTRYPOINT = 0x100500

ASMBFLAGS = 
ASMKFLAGS = -f elf

CFLAGS =  -c -m32
LDFLAGS = -e start -Ttext $(ENTRYPOINT) -m elf_i386 

ASM = nasm
DASM = ndisasm

CC = gcc
LD = ld

OSBOOT = bin/boot.bin bin/loader.bin
OSKERNEL = bin/kernel.bin
OBJS = bin/obj/kernel.o bin/obj/init.o


all:disk

bin/boot.bin: boot/boot.asm
	$(ASM) $(ASMBFLAGS) -o $@  $<

bin/loader.bin: boot/loader.asm
	$(ASM) $(ASMBFLAGS) -o $@ $<

bin/obj/kernel.o: kernel/kernel.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

bin/obj/init.o: kernel/init.c
	$(CC) $(CFLAGS) -o $@ $<

$(OSKERNEL) : $(OBJS)
	$(LD) $(LDFLAGS) -o $(OSKERNEL) $(OBJS)
	
	

disk: $(OSBOOT) $(OSKERNEL)
	dd if=bin/boot.bin of=../test/c.img bs=512 count=1 conv=notrunc
	dd if=bin/loader.bin of=../test/c.img bs=512 count=1 conv=notrunc seek=1
	dd if=bin/kernel.bin of=../test/c.img bs=512 count=20 conv=notrunc seek=2

clean:
	rm -f bin/*.lst bin/*.bin bin/obj/*.o
