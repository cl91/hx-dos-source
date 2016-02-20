
// sample showing different memory allocation methods for 16bit clients
// in Open Watcom

#include <stdio.h>
#include <direct.h>
#include <malloc.h>

#define INCL_BASE

#include <os2.h>

int main(int argc, char * * argv)
{
    char * pMem;
    char _far * fpMem;
    char _far * fpMem2;
    char _far * fpMem3;
    unsigned short sel;
    int i;

    // allocate memory from local heap with malloc()
    // local heap usually is < 64 kB

    for (i = 0; i < 8; i++)
        if (pMem = (char *)malloc(1024*(i+1))) {
            printf("malloc(0x%X) = %X\n",1024*(i+1),pMem);
        }

    // allocate memory from far heap with _fmalloc()
    // this heap is not restricted in size, but seems to be segmented
    // in 64 kB chunks in OW.

    for (i = 0; i < 5; i++) {
        fpMem = _fmalloc(0x2000*(i+1));
        printf("_fmalloc(0x%X)=%Fp\n", 0x2000*(i+1), fpMem);
    }

    // allocate 2 MB with DosAllocHuge()
    // this is a OS/2 API call, it will need 1 selector per 64 kB block.
    // Running on OS/2 the amount of memory is restricted to 16 MB,
    // but this limitation isnt true for HX. The limit in theory
    // is 64 * 8192 = 524288 kB (=512 MB), but some selectors will always
    // be in use already.

    DosAllocHuge(16*2,0,&sel,0,0);
    printf("DosAllocHuge(32*64 kB)=%X\n", sel);

    // alloc 0xFFFE0 bytes of memory with DOS call
    // the DOS API int 21h, ah=48h allocs paragraphs, and for 16bit
    // clients BX is used to hold the amount of paragraphs. However, BX=FFFFh
    // most likely will not work, that's why this call limits the memory size
    // to 0xFFFE0 bytes. the dpmi server hopefully will do the selector tiling
    // for the memory block allocated.

    _asm {
        mov dword ptr fpMem2,0
        mov ah,48h
        mov bx,0FFFEh
        int 21h
        jc label1
        mov word ptr fpMem2+2,ax
    label1:
    }
    printf("int 21h(ah=48h, bx=FFFE)=%Fp\n", fpMem2);

    // alloc 1 MB of memory with DPMI call. Just 1 selector is
    // allocated, so assembler will be needed to access anything
    // above the first 64 kB of the memory block

    _asm {
        mov dword ptr fpMem3,0
        mov bx,16
        mov cx,0
        mov ax,501h
        int 31h
        jc label2
        push bx
        push cx
        mov ax,0
        mov cx,1
        int 31h  ;alloc 1 selector only
        pop dx
        pop cx
        jc label2
        mov word ptr fpMem3+2,ax
        mov bx,ax
        mov ax,7
        int 31h  ;set base of selector
        mov cx,15
        mov dx,-1
        mov ax,8
        int 31h  ;set limit to 0xFFFFF
    label2:
    }
    printf("int 31h(ax=501h, bx:cx=100000h)=%Fp\n", fpMem3);

    // all memory will be released by the dpmi host when the client
    // terminates

    return 0;
}
