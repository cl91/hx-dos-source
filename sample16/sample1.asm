
;--- this source assembles with MASM (SAMPLE1M.MAK), TASM (SAMPLE1B.MAK)
;--- or WASM (SAMPLE1W.MAK)

        .286
        .model small
        .386

;--- the application is called with
;--- DS,SS=DGROUP
;--- ES=PSP
;--- CX=size of local heap
;--- BX=size of stack

ifdef ?MASM
InitTask proto far pascal
else
extrn    InitTask:far
endif

        .data
        
;--- the first 16 bytes of DGROUP are reserved as for win16 binaries

        dw 0,0,5,0,0,0,0,0
        
szMsg   db 13,10,"Hello, world",13,10,"$"

        .code

main    proc c

        mov dx, offset szMsg
        mov ah,9
        int 21h
        ret

main    endp

StartApp proc
        call InitTask   ;this call IS required for DPMI16
        and  ax,ax
        jz   exit
        push ss	        ;this mov makes the binary compatible with
        pop  ds         ;Borland's Powerpack and TD.EXE. To use TD,
                        ;activate stub "16stub.exe" in sample1.def
                        ;and relink the binary
        call main
exit:
        mov  ah,4ch
        int  21h
StartApp endp

        END StartApp

