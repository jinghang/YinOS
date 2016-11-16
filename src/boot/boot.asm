org 0x7c00
[bits 16]
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
;读 loader 到 0x7e00
call loader
;跳到 loader
jmp 0x7e0:0

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

loader:
mov ax,0x7e0
mov es,ax
mov bx,0    ;es:bx 指向接受从扇区读入数据的内存区
mov dl,80h  ;驱动器号
mov dh,0    ;磁头号
mov ch,0    ;磁道号
mov cl,2    ;扇区号
mov al,1    ;(al)=要读取的扇区数
mov ah,02H  ;功能号，表示读
int 13h
ret

times 510-($-$$) db 0
db 0x55,0xaa