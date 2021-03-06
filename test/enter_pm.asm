org 0x7c00

jmp code

;全局描述符表，表的每一行都是8个字节
gdt:
GDT_HOLD:db 0x00, 0x00, 0x00, 0x00, 0x00, 00000000b, 00000000b, 0x00 ; 占位
GDT_CODE:db 0xff, 0xff, 0x00, 0x00, 0x00, 10011010b, 11001111b, 0x00 ; 0~4GB 代码段
GDT_DATA:db 0xff, 0xff, 0x00, 0x00, 0x00, 10010010b, 11001111b, 0x00 ; 0~4BG 数据段
GdtLen equ $-gdt
gdtr:
    dw GdtLen-1 ; 描述符表中有3行数据，所以 8*3-1=23
    dd gdt; 描述符表的首地址

SelectorLDT equ GDT_CODE - gdt

code:
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
jmp dword SelectorLDT:ProtectModeEntry

jmp $


ProtectModeEntry:
mov eax,0x11
jmp $

times 510-($-$$) db 0
db 0x55,0xaa




