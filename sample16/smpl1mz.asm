
        .286
        .model small, c

;--- this source is used to create a MZ executable.
;--- A very simple startup module is linked in the binary (JMPPM16.OBJ),
;--- which switches to protected mode and then calls main() with:
;---  DS,SS=DGROUP
;---  ES=PSP
;---  SP=top of stack
;--- please note:
;---  + JMPPM16.OBJ is kept simple. It is intended to be used by ASM
;---    programs. There are no argc, argv arguments. if command line
;---    parameters are required, one will have to get them from PSP:[80h]
;---    or CMDLINE environment variable. For Open Watcom WCC there is
;---    another startup module supplied, JMPPM16W.OBJ, which supports
;---    C/C++ (SAMPL2MZ.MAK)
;---  + the binary is still in DOS conventional memory
;---  + there is no local heap and there is no free memory "above" sp.
;---    To get space for a local heap one may try to realloc the memory 
;---    block ES points to by calling int 21h, ah=4Ah, bx=1000h. Or simply
;---    define a block of memory in .data? segment

        .data
        
szMsg   db 13,10,"Hello, world",13,10,"$"

        .code

main    proc public

        mov dx, offset szMsg
        mov ah,9
        int 21h
        ret

main    endp

        END

