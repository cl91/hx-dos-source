
;--- worker for (w)sprintf, VC 1.5 compatible

		.286
        .model small

FILE struct
bufptr	dd ?
maxbuf	dw ?
buf2	dd ?
flags	db ?
res1	db ?
FILE ends

LBUFPTR  equ 4	;size of buffer pointer
LFSTRPTR equ 4	;size of format string pointer
LPARMPTR equ 4	;size of argument pointer
LFILEPTR equ 4	;size of FILE pointer

TMPBUFFSIZ equ 160	;size temp buffer

		.code

TransTab db 06h,00h,00h,06h,00h,01h,00h,00h ;00 <sp> ! " # $ % & '
         db 10h,00h,03h,06h,00h,06h,02h,10h ;08 ( ) * + , - . /
         db 04h,45h,45h,45h,05h,05h,05h,05h ;10
         db 05h,35h,30h,00h,50h,00h,00h,00h ;18
         db 00h,20h,20h,30h,50h,58h,07h,08h ;20
         db 00h,30h,30h,30h,57h,50h,07h,00h ;28
         db 00h,20h,20h,00h,00h,00h,00h,00h ;30
         db 08h,60h,60h,60h,60h,60h,60h,00h ;38
         db 00h,70h,70h,78h,78h,78h,78h,08h ;40
         db 07h,08h,00h,00h,07h,00h,08h,08h ;48
         db 08h,00h,00h,08h,00h,08h,00h,00h ;50
         db 08h                             ;58
sNull    db '(null)'
SIZNULL  equ $-sNull    ;size of (null)

vtab    dw  offset stdchar  ;0 simple char in formstr, just store it
        dw  offset esc1char ;1 char "%"
        dw  offset esc2char ;2 char "."
        dw  offset esc3char ;3 char "*"
        dw  offset clrprec  ;4 clear precision
        dw  offset setprec  ;5 set precision
        dw  offset fnspec   ;6 set F, N, L, l
        dw  offset typechar ;7 handle format type

if 1
_output	proc far c public uses si di tmpfile:far16 ptr FILE, formstr:far16 ptr BYTE, parms:far16 ptr WORD
else
_output	proc far c public uses si di tmpfile:ptr FILE, formstr:ptr BYTE, parms:ptr WORD
endif

local	var01:byte               ;to render 'x'/'X';offset 'a'/'A'
local	curchar:byte             ;bp-2;
local	var4:word                ;flags
local	var5:byte                ;bp-5
local	bBase:byte               ;bp-6 (base of number)
local	var7:word                ;bp-8 chars stored in buffer (max 7FFF)
local	var8:word                ;bp-a number
local	var9:word                ;bp-c (precision)
local	var11:word               ;bp-e prefix for numbers (+,-,0x)
local	var12:word               ;bp-10 prefix string max
local	var13:word               ;bp-12 not used
local	dsreg:word
local	tmpbuff[TMPBUFFSIZ]:byte

;*** var4 flags ***
; 01= '+'
; 02= ' '
; 04= '-'
; 08= unused
; 10= 'l'
; 20= 'F'
; 40= signed , not unsigned
; 80= '#'

        cld
        mov     [dsreg],ds
        xor     AX,AX
        mov     [var7],AX
        mov     [var5],AL
if LFSTRPTR eq 4
        mov     ds,word ptr formstr+2
endif
nextfchar:
        mov     SI,word ptr formstr+0
        lodsb
        mov     word ptr formstr+0,SI
        or      AL,AL
        je      done
        mov     [curchar],AL     ;store current char of format string
        mov     BX,offset TransTab
        sub     AL,' '
        cmp     AL,058h          ;"> 78h" = "> x"
        ja      @F
        xlat    cs:[TransTab]
        and     AL,0Fh
        jmp     transchar
@@:
		mov     AL,0
transchar:
		mov     CL,3             ;0->0,1->8,2->10,3->18,4->20,5->28,6->30
        shl     AL,CL            ;7->38,8->40
        add     AL,[var5]
        xlat    cs:[TransTab]
        inc     CL
        shr     AL,CL            ;Bits 4-7
        mov     [var5],AL
        cbw
        mov     BX,AX
        shl     BX,1
        mov     al,[curchar]
        call    word ptr cs:[BX+offset vtab]
        cmp     [var7],0000
        jge     nextfchar
done:
        mov     AX,[var7]
        mov     ds,[dsreg]
        ret

stdchar::
        mov     DL,AL            ;00 handle std chars
        mov     CX,1
        jmp     stochr1          ;just store this char

;--- reset VAR4, VAR8, VAR9 (-1), VAR12, VAR13

esc1char::                       ;01 handle '%'
        xor     AX,AX
        mov     [var12],AX
        mov     [var8],AX
        mov     [var13],AX
        mov     word ptr [var4],AX
        dec     AX
        mov     [var9],AX
        retn

;--- set VAR4

esc2char::                       ;02 handle "."
        mov     BL,4             ;format flags - + ' ' #
        cmp     AL,'-'
        je      @F
        mov     BL,1
        cmp     AL,'+'
        je      @F
        mov     BL,2
        cmp     AL,' '
        je      @F
        mov     BL,80h
        cmp     AL,'#'
        je      @F
        mov     BL,8
@@:
        or      byte ptr var4,BL
        retn

;--- set VAR8 (+VAR4, bit 3)

esc3char::                       ;03 handle '*'
        mov     CL,AL
        cmp     CL,'*'
        jne     @F
        call    getword
        or      AX,AX
        jns     esc3char_1
        neg     AX
        or      byte ptr [var4],4	;set '-' flag
        jmp     esc3char_1
@@:
		sub     CL,'0'
        xor     CH,CH
        mov     AX,[var8]
        mov     BL,10
        mul     BL
        add     AX,CX
esc3char_1:
		mov     [var8],AX
        retn

;--- reset VAR9        

clrprec::                                   ;04
        mov     word ptr [var9],0
        retn
        
;--- set precision (VAR9)
        
setprec::                                   ;05
        mov     CL,AL
        cmp     CL,'*'
        jne     @F
        call    getword
        or      AX,AX
        jns     setprec_1
        mov     AX,-1
        jmp     setprec_1
@@:     sub     CL,'0'
        xor     CH,CH
        mov     AX,[var9]
        mov     BL,10
        mul     BL
        add     AX,CX
setprec_1:
		mov     [var9],AX
        retn

;--- set VAR4, bits 4,5,10,11

fnspec::                                ;06
        mov     BL,10h
        cmp     AL,'l'
        jz      fnspec_2
        mov     BL,20h
        cmp     AL,'F'
        jz      fnspec_2
        mov     BL,10h
        cmp     AL,'N'
        jz      fnspec_1
        mov     BL,04h
        cmp     AL,'L'
        jz      fnspec_1
        mov     BL,08h
fnspec_1:
        or      byte ptr var4+1,BL
        retn
fnspec_2:
        or      byte ptr var4+0,BL
        retn

typechar::                                  ;07 handle 'type'
        push    offset storeitem
        cmp     AL,'d'
        jne     @F
        jmp     formatd
@@:     cmp     AL,'i'
        jne     @F
        jmp     formati
@@:     cmp     AL,'u'
        jne     @F
        jmp     formatu
@@:     cmp     AL,'X'
        jne     @F
        jmp     formatX
@@:     cmp     AL,'x'
        jne     @F
        jmp     formatx
@@:     cmp     AL,'o'
        jne     @F
        jmp     formato
@@:     cmp     AL,'c'
        je      formatc
        cmp     AL,'s'
        je      formats
        cmp     AL,'n'
        je      formatn
        cmp     AL,'p'
        je      formatp
        cmp     AL,'E'
        je      @F
        cmp     AL,'G'
        je      @F
        jmp     format?
@@:     jmp     formatEG

formatc:
		call    getword
        lea     DI,tmpbuff
        push    SS
        pop     ES
        stosb
        dec     DI
        mov     CX,1
        retn                          ;>> storeitem

formats:
ifdef _FAR_
        call    getfar16              ;s/tring - get far address
else
        call    getaddr               ;s/tring - get address
endif
        or      DI,DI
        jne     formats_1
        mov     AX,ES
        or      AX,AX
        jne     formats_1
        push    CS                    ;address == 0?
        pop     ES
        mov     DI,offset sNull       ;store text "(null)"
        mov     CX,SIZNULL
        retn                          ;>> storeitem
formats_1:   
		push    DI
        mov     CX,[var9]
        jcxz    formats_2
        xor     AL,AL
        repne   scasb                 ;get end of string
        jne     formats_2
        dec     DI
formats_2:   
		pop     CX
        sub     DI,CX                 ;store string size in CX
        xchg    CX,DI
        retn                          ;>> storeitem

formatn:
		call    getaddr               ;'n' (^Integer) - get address
        mov     AX,[var7]             ;store chars rendered so far in
        stosw                         ;this item
        test    byte ptr [var4],010h  ;precision l?
        je      @F
        xor     AX,AX                 ;then store a DWORD
        stosw
@@:
        pop     ax                    ;skip storeitem
        retn

;*** 'p' (far pointer), F/N? ***

formatp:
		mov     [var01],7
        test    byte ptr [var4],030h
        jne     @F
        call    getword
        jmp     formatp_1
@@:   
		call    getdword
        test    byte ptr [var4+1],018h
        jne     formatp_1
        push    DX
        xor     DX,DX
        lea     DI,tmpbuff+8
        mov     SI,4
        call    hexout
        mov     byte ptr tmpbuff+4,':'
        pop     AX
        mov     CX,9                           ;far16 ptr, size 9 chars
        jmp     formatp_2
formatp_1:   
		mov     CX,4
formatp_2:
		push    cx
        xor     DX,DX
        lea     DI,tmpbuff+3
        mov     SI,4
        call    hexout
        pop     cx
        retn                                   ;>> storeitem

;--- floats not implemented

formatEG:
		inc     word ptr [var13]       ;'G' + 'E'
format?:
		or      byte ptr [var4],040h
        pop     ax                     ;skip storeitem
        retn

;--------------------------------------------------------------------------

formatd:
formati:
		or      byte ptr [var4],040h   ;'d' + 'i'
formatu:
		mov     byte ptr [bBase],10	   ;'u'
        jmp     formatnum
formatX:   
		mov     [var01],7              ;'X'
        jmp     formatXx
formatx:   
		mov     [var01],027h           ;'x'
formatXx:
		test    byte ptr [var4],080h
        je      @F
        mov     word ptr [var12],2
        mov     byte ptr [var11],' '
        mov     DL,051h                      ;
        add     DL,[var01]
        mov     byte ptr [var11+1],DL
@@:
		mov     byte ptr [bBase],010h
        jmp     formatnum
formato:
		test    byte ptr [var4],080h         ;'o'
        je      @F
        or      byte ptr [var4+1],2
@@:   
		mov     byte ptr [bBase],8
formatnum:
        mov     bx,word ptr var4             ;BL=var4,BH=var3
        test    BL,10h
        je      @F
        call    getdword
        jmp     formatnum_1
@@:     call    getword
        test    BL,040h
        je      @F
        cwd
        jmp     formatnum_1
@@:     xor     DX,DX
formatnum_1:   
		test    BL,040h
        je      @F
        or      DX,DX
        jge     @F
        or      byte ptr [var4+1],1
        neg     AX
        adc     DX,0
        neg     DX
@@:  
		cmp     word ptr [var9],0
        jge     @F
        mov     word ptr [var9],1
        jmp     formatnum_2
@@:   
		and     byte ptr [var4],0F7h
formatnum_2:  
		mov     BX,AX
        or      BX,DX
        jne     @F
        mov     word ptr [var12],0
@@:   
		lea     DI,tmpbuff + TMPBUFFSIZ - 1
        mov     CL,[bBase]
        xor     CH,CH
        mov     SI,[var9]             ;precision
        call    numout
        test    byte ptr [var4+1],2
        je      formatnum_3
        jcxz    @F
        cmp     byte ptr es:[DI],'0'
        je      formatnum_3
@@:
		dec     DI
        mov     byte ptr es:[DI],'0'
        inc     CX
formatnum_3:
        retn                                     ;>> storeitem

;*** store item in buffer
;--- CX=num chars, ES:DI=Pointer

storeitem:
		mov     bx,var4               ;BL=var4,BH=var3
        test    BL,040h
        je      storeitem_2
        mov     ax,1
        test    BH,1
        je      @F
        mov     byte ptr [var11],'-'
        mov     [var12],ax
        jmp     storeitem_2
@@:     test    BL,1
        je      @F
        mov     byte ptr [var11],'+'
        mov     [var12],ax
        jmp     storeitem_2
@@:     test    BL,2
        je      storeitem_2
        mov     byte ptr [var11],' '
        mov     [var12],ax
storeitem_2:
		mov     AX,[var8]
        sub     AX,CX
        sub     AX,[var12]
        jge     @F
        xor     AX,AX
@@:     push    ES
        push    DI
        push    CX
        test    BL,0Ch
        jne     @F
        mov     CX,AX
        mov     DL,' '
        call    stochr                  ;leading blanks abspeichern
@@:
        mov     CX,[var12]
        jcxz    @F
        push    AX
        push    SS
        pop     ES
        lea     DI,[var11]
        call    movchr                  ;store prefix 
        pop     AX
@@:
        test    byte ptr [var4],8
        je      @F
        test    byte ptr [var4],4
        jne     @F
        mov     CX,AX
        mov     DL,'0'
        call    stochr                  ;store leading zeros
@@:     pop     CX
        pop     DI
        pop     ES
        push    AX
        call    movchr                  ;store item itself
        pop     AX
        test    byte ptr [var4],4
        je      @F
        mov     CX,AX
        mov     DL,' '
        call    stochr                  ;store trailing blanks
@@:
        retn

;*** helpers

;--- get next parameter (WORD)

getword:
if LPARMPTR eq 4
		push	ds
		lds		si, [parms]
        lodsw
		pop		ds
else
		mov     SI,[parms]
        lods    word ptr ss:[parms]    ;will this work generally?
endif
        mov     word ptr [parms+0],SI
        retn

;--- get next parameter (DWORD)

getdword:
if LPARMPTR eq 4
		push	ds
		lds     SI,[parms]
        lodsw
        xchg    DX,AX
        lodsw
		pop 	ds
else
		mov     SI,[parms]
        lods    word ptr ss:[parms]
        xchg    DX,AX
        lods    word ptr ss:[parms]
endif        
        xchg    DX,AX
        mov     word ptr [parms+0],SI
        retn

;*** get an address from parameters

getaddr:test    byte ptr [var4],020h	;get FAR/NEAR parameter
        je      @F
getfar16:			                    ;get far16 address
        call    getdword
        mov     ES,DX
        mov     DI,AX
        retn
@@:
		call    getword                 ;get near address
        mov     DI,AX
        or      AX,AX
        jz      @F
        mov     ax,[dsreg]
@@:
        mov     ES,AX
        retn

;*** copy cx chars from ES:DI to buffer

movchr: 
		jcxz    movchr_done
        add     [var7],CX
;        push    DI
        mov      SI,DI
if LFILEPTR eq 4
		push	ds
        lds     BX,tmpfile
        sub     [bx.FILE.maxbuf],cx  ;adjust remaining size of buffer (7FFF)
else
        mov     BX,tmpfile
        sub     ss:[bx.FILE.maxbuf],cx
endif   
        jns     @F
        mov     [var7],0FFFFh		 ;buffer overflow
if LFILEPTR eq 4
        add     cx,[bx.FILE.maxbuf]
else
        add     cx,ss:[bx.FILE.maxbuf]
endif        
@@:
if LFILEPTR eq 4
		push	es
        pop		ds
        les     DI,[bx.FILE.bufptr]
;		pop		ds
        rep     movsb
;        push	ds
        lds		bx, tmpfile
        mov     word ptr [bx.FILE.bufptr],di
        pop		ds
else
  if LBUFPTR eq 2
        mov     DI,ss:[bx.FILE.bufptr]
        push    ds
        pop     es
        rep     movsb
  else
        push    ds
        push    es
        pop     ds
        les     DI,ss:[bx.FILE.bufptr]
        rep     movsb
        pop     ds
  endif
        mov     ss:[bx.FILE.bufptr],di
endif        
;        pop     DI
movchr_done:
        retn

;*** store cx chars (in DL) in buffer (DI)

stochr: 
		jcxz    stochr_done	;no chars at all
stochr1:
        add     [var7],CX
;        push    DI
if LFILEPTR eq 4
		push	ds
        lds     BX,[tmpfile]
        sub     [bx.FILE.maxbuf],cx
else
        mov     BX,[tmpfile]
        sub     ss:[bx.FILE.maxbuf],cx
endif        
        jns     @F
        mov     word ptr [var7],0FFFFh
if LFILEPTR eq 4
        add     cx,[bx.FILE.maxbuf]
else
        add     cx,ss:[bx.FILE.maxbuf]
endif 
@@:
if LFILEPTR eq 4
        les     DI,[bx.FILE.bufptr]
        mov     AL,DL
        rep     stosb
        mov     word ptr [bx.FILE.bufptr],di
        pop		ds
else
if LBUFPTR eq 2
        mov     DI,ss:[bx.FILE.bufptr]
        push    ds
        pop     es
else
        les     DI,ss:[bx.FILE.bufptr]
endif
        mov     AL,DL
        rep     stosb
        mov     ss:[bx.FILE.bufptr],di
endif
;       pop     DI
stochr_done:
		retn

;*** render number right aligned in buffer (on stack)
;*** DX:AX: number
;*** SI: max number of digits
;*** CX: Base (10,16,8)
;*** SS:DI-> buffer

hexout:						;<--- base 0x0010
		mov     cx,0010h
numout:                     ;<--- base in CX
		std
        push    DI
        xchg    AX,BX
        push    ss
        pop     es
nextitem:
		or      SI,SI
        jg      @F
        or      BX,BX
        jne     @F
        or      DX,DX
        jz      numdone
@@:     xchg    AX,DX
        xor     DX,DX
        div     CX
        xchg    AX,BX
        div     CX
        xchg    AX,DX
        xchg    DX,BX
        add     AL,'0'
        cmp     AL,'9'
        jbe     @F
        add     AL,[var01]
@@:   
		stosb
        mov     AX,DX
        dec     SI
        jmp     nextitem
numdone:
		pop     CX
        sub     CX,DI
        inc     DI
        cld
        retn

_output	endp


end

