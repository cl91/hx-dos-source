
;--- a Win32 console application with FASM
;--- linked with HX's DPMIST32.BIN, so it also runs in DOS with HX

format MS COFF

section '.data' data readable writeable

dwWritten dd 0
szText db 'hello world',13,10

extrn '__imp__ExitProcess@4' as ExitProcess:dword
extrn '__imp__WriteConsoleA@20' as WriteConsole:dword
extrn '__imp__GetStdHandle@4' as GetStdHandle:dword

section '.text' code

public _start

_start:

	push	-11				;STD_OUTPUT_HANDLE
    call	[GetStdHandle]
    mov		ebx, eax
    push	0
	push	dwWritten
    mov		ecx,13
	push	ecx
	push	szText
	push	ebx
	call	[WriteConsole]
	push	0
	call	[ExitProcess]

