
;--- this is a OS/2 16-bit application

        .286
        .model small

VioWrtTty proto far pascal :FAR16 ptr, :WORD, :WORD
DosExit   proto far pascal :WORD, :WORD

        .data
        
szMsg   db "Hello, world",13,10
sizemsg equ $ - szMsg

szMsg2  db "CS="
bCS		db "    ",13,10
sizemsg2 equ $ - szMsg2

        .code

word2asc proc
		push ax
        mov al,ah
        call byte2asc
        pop ax
byte2asc:        
		push ax
        shr al,4
        call nib2asc
        pop ax
nib2asc:
		and al,0Fh
        add al,'0'
        cmp al,'9'
        jbe @F
        add al,7
@@:
		stosb
		ret
word2asc endp

start:
        invoke VioWrtTty, addr szMsg, sizemsg, 0
        mov ax,cs
        mov di,offset bCS
        push ds
        pop es
        call word2asc
        invoke VioWrtTty, addr szMsg2, sizemsg2, 0
        invoke DosExit, 1, 0

        END start

