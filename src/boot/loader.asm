org 0x7e00

jmp start

;全局描述符表，表的每一行都是8个字节
gdt:
GDT_HOLD: db 0x00, 0x00, 0x00, 0x00, 0x00, 00000000b, 00000000b, 0x00 ; 占位
GDT_CODE: db 0xff, 0xff, 0x00, 0x00, 0x00, 10011010b, 11001111b, 0x00 ; 0~4GB 代码段
GDT_DATA: db 0xff, 0xff, 0x00, 0x00, 0x00, 10010010b, 11001111b, 0x00 ; 0~4BG 数据段
GDT_VIDEO:db 0xff, 0xff, 0x00, 0x80, 0x0b, 10010010b, 11001111b, 0x00 ; 0~4BG 显示段
GdtLen equ $-gdt    ;描述符表长度
gdtr:
    dw GdtLen-1 ; 描述符表中有3行数据，所以 8*3-1=23
    dd gdt; 描述符表的首地址
;段选择子
SelectorCode  equ GDT_CODE  - gdt
SelectorData  equ GDT_DATA  - gdt
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
mov eax,SelectorData
mov es,ax
mov ds,ax
mov fs,ax
mov ss,ax
mov eax,SelectorVideo
mov gs,ax
mov esp,0x100400    ;设置堆栈

;读内核到内存中
; https://0cch.com/minikernel/2013/08/26/e4-bd-bf-e7-94-a8pci-ide-controller-e8-af-bb-e5-86-99-e7-a1-ac-e7-9b-98-1.html

mov dx,0x01f1   ;将状态清清0
mov al,0
out dx,al

mov dx,0x01f2   ;读取扇区数的端口号
mov al,20     ;读取20个扇区
out dx,al

mov dx,0x01f3   ;LBA起始扇区号 0~7 位 端口号
mov al,0x02     ;读第三个扇区，从0开始编码
out dx,al

inc dx          ;0x01f4
mov al,0x00
out dx,al       ; 8~15 位

inc dx          ;0x01f5
mov al,0x00
out dx,al       ; 16~23 位

inc dx          ;0x01f6
mov al,0xe0     ;LBA模式，主硬盘，以及LBA扇区号 24~27 位
out dx,al

mov dx,0x01f7
mov al,0x20     ;读命令
out dx,al

;等待硬盘就绪
.waits:
    in al,dx
    test al,8
    jz .waits

;下面开始读数据到指定地址
mov edi,0x100500;es:edi 存放数据的目的地址
mov ecx,512/2
mov dx,0x01f0   ;数据端口
rep insw        ;从端口复制到目的地址

jmp 0x100500    ;跳到内核

nop

hlt;CPU暂停


