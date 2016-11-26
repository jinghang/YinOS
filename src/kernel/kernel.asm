[bits 32]
extern init

global write_mem8

start:
mov edi,0
mov ah,0CH
mov al,'K'
mov [gs:edi],ax

call init
hlt

;
write_mem8:     ;void write_mem8(int addr, int data);
mov ecx,[esp+4] ;第一个参数
mov al,[esp+8]  ;第二个参数
mov [gs:ecx],al
ret

jmp $