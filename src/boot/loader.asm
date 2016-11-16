org 0x7e00
[bits 16]
start:
;清屏
;call clean_screen
;初始化
mov ax,0
mov ds,ax;数据段基地址
mov ax,0xb800
mov es,ax;显卡的基地址
mov cx,show_msg-msg;字符串长度
mov di,0
mov si,msg
;显示字符串
call show_msg
hlt;CPU暂停


msg:
db "Loading......"

show_msg:
mov al,[si]
mov [es:di],al
add di,2
inc si
loop show_msg
ret
