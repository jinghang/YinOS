
void write_mem8(int addr, int data);

void init(void){
    char *show = 0xb8010;
    *show = 'B';
    write_mem8((int)0xb8012,(int)'C');
}