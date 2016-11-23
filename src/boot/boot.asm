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

;通过LBA读取硬盘
loader:
mov ax,0x7e0
mov ds,ax
mov bx,0        ; ds:bx 存放数据的目的地址

mov dx,0x01f2   ;读取扇区数的端口号
mov al,0x01     ;读取1个扇区
out dx,al

mov dx,0x01f3   ;LBA起始扇区号 0~7 位 端口号
mov al,0x01     ;读第二个扇区，从0开始编码
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
    and al,0x88
    cmp al,0x08
    jnz .waits

;下面开始读数据到指定地址
mov cx,256
mov dx,0x01f0   ;数据端口
.readw:
    in ax,dx
    mov [bx],ax
    add bx,2
    loop .readw

ret

times 510-($-$$) db 0
db 0x55,0xaa