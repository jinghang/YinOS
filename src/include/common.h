#ifndef _INCLUDE_COMMON_H_
#define _INCLUDE_COMMON_H_

#include "types.h"

//写内存
static inline void write_mem(void * dest, uint8_t c){
    __asm__ __volatile__ ("movb %1,(%0)"::"r"(dest),"r"(c));
}

#endif //_INCLUDE_COMMON_H_