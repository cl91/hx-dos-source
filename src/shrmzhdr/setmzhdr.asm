
;--- set mz header so file will just be loaded until stack

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

text1   db 'usage: setmzhdr [-q] filename',13,10
        db 0
text2a  db 'setmzhdr: file ',0
text2b  db ' not found',13,10,00
text4   db 'setmzhdr: dos seek error',13,10,00
text5   db 'setmzhdr: dos read error',13,10,00
text6   db 'setmzhdr: field SS in header is ZERO.',13,10,00
text7   db 'setmzhdr: dos write error',13,10,00
text8   db 'setmzhdr: not a MZ executable',13,10,00
text10a db "setmzhdr: ",0
text10b db " modified",13,10,0

	.data

bQuiet  db 0
text9   db 'setmzhdr: SP set to '
text9v  db '____h',13,10,00

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

;--- write word in AX as a string to [DI]

wordout proc
	push ax
	mov  al,ah
	call byteout
	pop  ax
byteout:
	push ax
	shr  al,4
	call nibout
	pop  ax
nibout:
	and  al,0Fh
	add  al,'0'
	cmp  al,'9'
	jbe @F
	add  al,7
@@:
	mov [di],al
	inc di
	ret
wordout endp

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

;*** get parameter ***

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
		.if (al == 'q')
			mov bQuiet, 1
			dec cl
			jmp nextparm
		.endif
		jmp parerr1
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

getpar endp

;*** set mz header fields SP and SS

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
	invoke DosRead, hFile, addr mzhdr, 20h
	.if (CARRY?)
		invoke StringOut, addr text5
		jmp exit
	.endif

;--- 1. task: set a sp of 0x200 if it's zero

	mov ax, mzhdr.e_sp
	and ax, ax
	jnz @F
	mov ax, 200h
	mov mzhdr.e_sp, ax
	cmp bQuiet,0
	jnz @F
	push ax
	mov di,offset text9v
	call wordout
	invoke StringOut, addr text9
	pop ax
@@:
	mov cx, ax
	and cx, 0Fh
	shr ax, 4
	jcxz @F
	inc ax
@@:
;--- the stack value can safely be set as heap min as well.
	mov mzhdr.e_minalloc, ax

;--- 2. task: reduce size of memory image. Just the 16bit part
;--- of the binary is to be loaded by the DOS loader.
;--- Usually SS can be used to get the 16bit size.
;--- However, for WLink this isn't true, because
;--- that linker won't set this field if stack size is zero!

	mov ax, mzhdr.e_ss
	and ax, ax
	jnz @F
	invoke StringOut, addr text6
	jmp exit
@@:
	add ax, mzhdr.e_cparhdr	;add size of header
	mov cx, ax
	and cx, 1Fh
	shr ax, 5
	jcxz @F
	inc ax
@@:
	mov mzhdr.e_cp,ax
	shl cx, 4
	mov mzhdr.e_cblp,cx

	invoke DosSeek, hFile, 0h, 0
	.if (CARRY?)
		invoke StringOut, addr text4
		jmp exit
	.endif
	invoke DosWrite, hFile, addr mzhdr, 20h
	.if (CARRY? || (ax != 20h))
		invoke StringOut, addr text7
		jmp exit
	.endif
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
