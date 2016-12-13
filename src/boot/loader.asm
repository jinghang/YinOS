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

;////////////////////////////////////////////////////////////////////////////
; 一些常量
;///////////////////////////////////////////////////////////////////////////
TopOfStack              equ 0x7000
BaseOfLoaderPhyAddr     equ 0x7e00
BaseOfKernelFilePyhAddr equ 0x10000
KernelEntryPhyAddr      equ 0x100500


;/////////////////////////////////////////////////////////////////////////
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
[SECTION .s32]
ALIGN 32
[BITS 32]
ProtectModeEntry:
mov eax,SelectorData
mov es,ax
mov ds,ax
mov fs,ax
mov ss,ax
mov eax,SelectorVideo
mov gs,ax
mov esp,TopOfStack    ;设置堆栈

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
mov edi,BaseOfKernelFilePyhAddr;es:edi 存放数据的目的地址
mov ecx,512*20/2
mov dx,0x01f0   ;数据端口
rep insw        ;从端口复制到目的地址

call move_kernel

jmp SelectorCode:KernelEntryPhyAddr    ;跳到内核


nop

hlt;CPU暂停

;--------------------------------------------------------
; 根据elf数据复制内核到指定地址
;--------------------------------------------------------
move_kernel:
    xor esi,esi;esi清零清零
    mov cx,word [BaseOfKernelFilePyhAddr+0x2c]  ; program header 的数量数量
    movzx ecx,cx
    mov esi,[BaseOfKernelFilePyhAddr+0x1c]      ; program header 的偏移偏移
    add esi,BaseOfKernelFilePyhAddr             ; program header 的物理地址地址

    .Begin:
    mov eax,[esi+0]
    cmp eax,0
    jz .NoAction

    ;开始调用 void* memcpy(void * dest, const void * src, int size);
    push dword [esi+0x10]   ;要复制的长度长度 p_filesz
    mov eax,[esi+0x04]      ;要复制的源地址偏移偏移
    add eax,BaseOfKernelFilePyhAddr
    push eax                ;要复制的源地址
    push dword [esi+0x08]   ;要复制到的目的地址
    call memcpy
    add esp,12              ;还原堆栈，三个参数 4X3=12

    .NoAction:
    add esi,0x20    ; 每个 program header 长32个字节，esi指向下一个 program header 
    dec ecx
    jnz .Begin

    ret

;-----结束结束--------------------------------------------

;----------------------------------------------------------
; //内存拷贝函数
; void* memcpy(void * dest, const void * src, int size);
;----------------------------------------------------------
memcpy:
    push    ebp
    mov ebp,esp ;保存栈顶,然后用用epb来读参数

    push esi    ;保存寄存器数据
    push edi
    push ecx

    mov edi,[ebp+ 8] ;dest，因为有有 push ebp 所以加8
    mov esi,[ebp+12] ;src
    mov ecx,[ebp+16] ;size

    rep movsb   ;开始传送

    mov eax,[ebp+8];返回目的地址

    ;还原寄存器
    pop ecx
    pop edi
    pop esi
    mov esp,ebp
    pop ebp

    ;函数返回返回
    ret
;----------------------
; // memcpy 结束
;-------------------------------------------------------

;//////////////////////////////////////////////////////////////////////
[SECTION .data1]
ALIGN 32
LABEL_DATA:



