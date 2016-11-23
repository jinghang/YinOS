org 0x7e00

jmp start

;全局描述符表，表的每一行都是8个字节
gdt:
GDT_HOLD:db 0x00, 0x00, 0x00, 0x00, 0x00, 00000000b, 00000000b, 0x00 ; 占位
GDT_CODE:db 0xff, 0xff, 0x00, 0x00, 0x00, 10011010b, 11001111b, 0x00 ; 0~4GB 代码段
GDT_DATA:db 0xff, 0xff, 0x00, 0x00, 0x00, 10010010b, 11001111b, 0x00 ; 0~4BG 数据段
GDT_VIDEO:db 0xff, 0xff, 0x00, 0x80, 0x0b, 10010010b, 11001111b, 0x00 ; 0~4BG 数据段
GdtLen equ $-gdt    ;描述符表长度
gdtr:
    dw GdtLen-1 ; 描述符表中有3行数据，所以 8*3-1=23
    dd gdt; 描述符表的首地址
;段选择子
SelectorCode equ GDT_CODE - gdt
SelectorData equ GDT_DATA - gdt
SelectorVideo equ GDT_VIDEO - gdt

msg:
db "Loading......"
MsgLen equ $-msg

[section .s16]
[bits 16]
show_msg:
mov al,[si]
mov [es:di],al
add di,2
inc si
loop show_msg
ret

start:
;初始化
mov ax,0
mov ds,ax;数据段基地址
mov ax,0xb800
mov es,ax;显卡的基地址
mov cx,MsgLen;字符串长度
mov di,0
mov si,msg
;显示字符串
call show_msg

;加载 GDTR 
lgdt [gdtr]
;关中断
cli
;打开A20地址线
in al,92h
or al,00000010b
out 92h,al
;置CR0的PE位，Protect Enable
mov eax,cr0
or eax,1
mov cr0,eax

;真正进入保护模式
jmp dword SelectorCode:ProtectModeEntry

jmp $

;32位保护模式代码
[section .s32]
[bits 32]
ProtectModeEntry:
mov ax,SelectorData
mov ds,ax
mov ax,SelectorVideo
mov gs,ax
mov edi,0
mov ah,0CH
mov al,'K'
mov [gs:edi],ax

;读内核到内存中


jmp $

hlt;CPU暂停


