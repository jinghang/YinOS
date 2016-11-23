[bits 32]
extern init

start:
mov edi,0
mov ah,0CH
mov al,'K'
mov [gs:edi],ax

call init

jmp$