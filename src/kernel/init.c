void write_mem8(unsigned int addr, char c);
#include <types.h>

//写内存
void write_mem(void * dest, uint8_t c){
    __asm__ __volatile__ ("movb %1,(%0)"::"r"(dest),"r"(c));
}

void init(void){
    char *show = (char*)0xb8010;
    *show = 'B';
    write_mem8(0xb8012,'C');
    write_mem(0xb8014,'D');
}