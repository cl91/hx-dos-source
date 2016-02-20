
;--- shrink mz header to the smallest possible size 
;--- should work with any DOS MZ binary linked with MS link
;--- as long as size is < 64 kB

	.286
	.model small, stdcall
	.dosseg
	option proc:private

@DosOpen macro pszName, mode
	mov dx,pszName
	mov ax,3D00h + mode
	int 21h
	endm
@DosClose macro hFile
	mov bx,hFile
	mov ah,3Eh
	int 21h
	endm

O_RDONLY equ    0
O_WRONLY equ    1
O_RDWR   equ    2

	.stack 1024

;--- structure MZ header (copied from winnt.inc)
        
IMAGE_DOS_HEADER STRUCT
  e_magic           WORD      ?		;+0		"MZ"
  e_cblp            WORD      ?		;+2		number of bytes in last page
  e_cp              WORD      ?		;+4		number of pages
  e_crlc            WORD      ?		;+6		number of relocation records
  e_cparhdr         WORD      ?		;+8		size header in paragraphs
  e_minalloc        WORD      ?		;+10
  e_maxalloc        WORD      ?		;+12
  e_ss              WORD      ?		;+14
  e_sp              WORD      ?		;+16
  e_csum            WORD      ?		;+18
  e_ip              WORD      ?		;+20
  e_cs              WORD      ?		;+22
  e_lfarlc          WORD      ?		;+24	begin relocation records
  e_ovno            WORD      ?		;+26
  e_res             WORD   4 dup(?)	;+28
  e_oemid           WORD      ?		;+36
  e_oeminfo         WORD      ?		;+38
  e_res2            WORD  10 dup(?)	;+40
  e_lfanew          DWORD      ?	;+60	
IMAGE_DOS_HEADER ENDS

	.const

text1   db 'usage: shrmzhdr [ options ] filename',13,10
		db '   -d: start relocation table may be below 0x40',13,10
        db 0
text2a  db 'shrmzhdr: file ',0
text2b 	db ' not found',13,10,00
text3	db "shrmzhdr: header size not 200h bytes",13,10,0
text4   db 'shrmzhdr: dos seek error',13,10,00
text5   db 'shrmzhdr: dos read error',13,10,00
text6	db "shrmzhdr: relocation entries not 0",13,10,0
text7   db 'shrmzhdr: dos write error',13,10,00
text8   db 'shrmzhdr: not a MZ executable',13,10,00
text9	db 'shrmzhdr: binary must be at least 1C0h size',13,10,0
text10a	db "shrmzhdr: ",0
text10b	db " shrinked successfully",13,10,0
if 1
text11	db "shrmzhdr: out of memory",13,10,0
else
text11	db "shrmzhdr: out of memory ("
msize   db "    )",13,10,0
endif
text12	db "shrmzhdr: binary too large (max size is 65536-512 bytes)",13,10,0

	.data

wRelocPos	dw 0040h        ;min pos of relocation table
dwFileBuff  dd 0
wFileSize   dw 0

	.data?
        
mzhdr	IMAGE_DOS_HEADER <>
		db (200h - sizeof IMAGE_DOS_HEADER) dup (?)

	.code

DosRead proc uses ds hFile:WORD, pBuffer:far ptr byte, wSize:WORD
	mov cx,wSize
	lds dx,pBuffer
	mov bx,hFile
	mov ax,3F00h
	int 21h
	ret
DosRead endp

DosWrite proc uses ds hFile:WORD, pBuffer:far ptr byte, wSize:WORD
	mov cx,wSize
	lds dx,pBuffer
	mov bx,hFile
	mov ax,4000h
	int 21h
	ret
DosWrite endp

DosSeek proc hFile:WORD, dwOffs:DWORD, wMethod:WORD
	mov bx,hFile
	mov cx,word ptr dwOffs+2
	mov dx,word ptr dwOffs+0
	mov al,byte ptr wMethod
	mov ah,42h
	int 21h
	ret
DosSeek endp

STDOUT	equ 1

StringOut proc uses bx pszString:ptr byte
	mov cx, pszString
	mov bx, cx
	.while (byte ptr [bx])
		inc bx
	.endw
	sub bx, cx
	invoke DosWrite, STDOUT, ds::cx, bx
	ret
StringOut endp

;*** parameter holen ***

getpar  proc pszFN:ptr byte

	mov bx,0080h
	mov cl,byte ptr es:[bx]
nextparm:        
	.if (!cl)
		jmp parerr1
	.endif
	inc bx
	.while (cl)
		mov al,es:[bx]
		.break .if (al != ' ')
		inc bx
		dec cl
	.endw
	.if (!cl)
		jmp parerr1
	.endif
	.if ((al == '/') || (al == '-'))
		inc bx
		dec cl
		.if (!cl)
			jmp parerr1
		.endif
		mov al,es:[bx]
		or al, 20h
		.if (al == 'd')
			mov wRelocPos, 001Eh
		.else
			jmp parerr1
		.endif
		dec cl
		jmp nextparm
	.endif
	mov si,pszFN
	.while (cl)
		mov al,es:[bx]
		mov [si],al
		inc bx
		inc si
		dec cl
	.endw
	mov byte ptr [si],0
	mov ax,1
	ret
parerr1:
	xor ax,ax
	ret

getpar  endp

if 0
wordout proc
	push ax
	mov al,ah
	call byteout
	pop  ax
byteout:
	push ax
	shr al,4
	call nibout
	pop ax
nibout:
	and al,0Fh
	add al,'0'
	cmp al,'9'
	jbe @F
	add al,7
@@:
	mov [di],al
	inc di
	ret
wordout endp
endif

;*** shrink header

patch proc pszFN:ptr byte

local	rc:WORD
local	hFile:WORD

	mov rc, 1
	@DosOpen pszFN, O_RDWR
	.if (CARRY?)
		invoke StringOut, addr text2a
		invoke StringOut, pszFN
		invoke StringOut, addr text2b
		mov ax, rc
		ret
	.endif
	mov hFile,ax
	invoke DosRead, hFile, addr mzhdr, 200h
	.if (CARRY?)
		invoke StringOut, addr text5
		jmp exit
	.endif
	cmp word ptr mzhdr.e_cparhdr,20h	;header size must be 20h
	.if (!ZERO?)
		invoke StringOut, addr text3
		jmp exit
	.endif
if 0
	cmp word ptr mzhdr.e_crlc,0h		;relocation entries must be 0
	.if (!ZERO?)
		invoke StringOut, addr text6
		jmp exit
	.endif
endif
	mov ax, mzhdr.e_cp					;size in 512 bytes units
	cmp ax, 64*2						;file size must be < 64 kB
	.if (!CARRY?)
		invoke StringOut, addr text12
		jmp exit
	.endif
	cmp mzhdr.e_cblp,0
	jz @F
	dec ax					;adjust for last page
@@:
	dec ax					;dont count header
	shl ax, 9
	add ax, mzhdr.e_cblp
	mov wFileSize, ax		;size in bytes without header
	mov bx, ax
	shr bx, 4				;bytes -> paragraphs (16)
	inc bx
;	mov si, bx
	mov ah,48h
	int 21h
	.if (CARRY?)
;		mov di, offset msize
;		 mov ax, si
;		 call wordout
		invoke StringOut, addr text11	;out of memory
		jmp exit
	.endif
	mov word ptr dwFileBuff+2, ax

	invoke DosSeek, hFile, 200h, 0
	.if (CARRY?)
		invoke StringOut, addr text4
		jmp exit
	.endif
	invoke DosRead, hFile, dwFileBuff, wFileSize
	.if (CARRY?)
		invoke StringOut, addr text5
		jmp exit
	.endif
	cmp ax,wFileSize
	.if (!ZERO?)
		invoke StringOut, addr text9
		jmp exit
	.endif

;	mov ax, wRelocPos
;	mov mzhdr.e_lfarlc,ax				;set begin relocs
;	mov mzhdr.e_cblp,0					;set bytes last page = 0
	mov ax,mzhdr.e_crlc					;no of relocations
	.if (ax)
		shl ax,2						;each reloc requires 4 bytes
		add ax, mzhdr.e_lfarlc
	.else
		mov ax, wRelocPos
	.endif
	test al,0Fh
	jz @F
	and al,0F0h
	add ax,10h
@@:            
	shr ax, 4
	mov cx, mzhdr.e_cparhdr
	mov mzhdr.e_cparhdr,ax				;size header in paras

	shl ax,4
	add ax, wFileSize
	mov cx, ax
	shr ax, 9
	and cx, 01FFh
	jcxz @F
	inc ax
@@:
	mov mzhdr.e_cblp,cx
	mov mzhdr.e_cp,ax

	invoke DosSeek, hFile, 0, 0
	mov ax, mzhdr.e_cparhdr
	shl ax, 4
	mov cx, ax
	invoke DosWrite, hFile, addr mzhdr, cx
	.if (CARRY? || (ax != cx))
		invoke StringOut, addr text7
		jmp exit
	.endif
	invoke DosWrite, hFile, dwFileBuff, wFileSize
	invoke DosWrite, hFile, addr mzhdr, 0	; truncate file

	invoke StringOut, addr text10a
	invoke StringOut, pszFN
	invoke StringOut, addr text10b
	mov rc,0
exit:
	@DosClose hFile
	mov ax,rc
	ret
patch endp

main proc

local	szFN[100]:byte

	invoke getpar, addr szFN		;get parameters
	.if (!ax)
		invoke StringOut, addr text1
		mov ax, 1
		ret
	.endif
	invoke patch, addr szFN
	ret
main endp

start:
	mov  ax,ss
	mov  cx,ds
	sub  ax,cx
	mov  cx,sp
	shr  cx,4
	add  ax,cx
	mov  bx,ax
	mov  ah,4ah
	int  21h
	mov  ax, DGROUP
	mov  ds, ax
	mov  cx, ss
	sub  cx, ax
	shl  cx, 4
	mov  ss, ax
	add  sp, cx
	call main
	mov  ah,4ch
	int  21h

	END start
