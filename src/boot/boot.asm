org 0x7c00

start:
;清屏
call clean_screen
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

;清屏
clean_screen:
mov ah,0x06
mov al,0x00
mov bh,0x07;白底黑字
mov ch,0;0行0列到23行79列
mov cl,0
mov dh,24
mov dl,79
int 10h
ret

msg:
db "Welcom to YinOS"

show_msg:
mov al,[si]
mov [es:di],al
add di,2
inc si
loop show_msg
ret

times 510-($-$$) db 0
db 0x55,0xaa