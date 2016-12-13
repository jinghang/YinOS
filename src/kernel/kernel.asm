[bits 32]
extern init

global write_mem8
global start

[section .text]
start:
mov edi,0
mov ah,0CH
mov al,'K'
mov [gs:edi],ax

call init
hlt

;---------------------------------------------------------
; void * write_mem8(void * dest, char c)
;---------------------------------------------------------
write_mem8:
    push ebp
    mov ebp,esp

    push edi

    mov edi,[ebp+8] ;第一个参数
    mov eax,[ebp+12]  ;第二个参数
    mov [edi],al

    pop edi

    mov esp,ebp
    pop ebp

    ret

jmp $