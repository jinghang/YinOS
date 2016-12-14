void write_mem8(unsigned int addr, char c);
#include <types.h>
#include <common.h>

void init(void){
    char *show = (char*)0xb8010;
    *show = 'B';
    write_mem8(0xb8012,'C');
    write_mem(0xb8014,'D');
}