
;--- RTM "clone"

		.286
		.model small
		.386

		include dpmi.inc

GlobalAlloc proto far pascal :WORD, :DWORD
GlobalFree  proto far pascal :WORD
GlobalRealloc proto far pascal :WORD, :DWORD, :WORD
GlobalSize  proto far pascal :WORD
GetFreeSpace proto far pascal :WORD

		.code

RTMGETVERSION proc far pascal
		int 3
		mov  ax,1
		ret
RTMGETVERSION endp

MEMINITSWAPFILE proc far pascal
		int 3
		mov  ax,1
		ret
MEMINITSWAPFILE endp

MEMCLOSESWAPFILE proc far pascal
		int 3
		mov  ax,1
		ret
MEMCLOSESWAPFILE endp

MEMALLOCATEBLOCK proc far pascal hHeap:word, wSize:word, wAttr:word, dwEvntProc:dword, lpSel:far16 ptr WORD
		mov ax,wSize
		xor dx,dx
		invoke GlobalAlloc, 0, dx::ax
		and ax,ax
		jz error
		push ds
		lds bx, lpSel
		mov [bx],ax
		pop ds
		xor ax,ax
		ret
error:
		mov ax,8	;out of memory?
		ret
MEMALLOCATEBLOCK endp

MEMFREEBLOCK proc far pascal wSel:WORD
		invoke GlobalFree, wSel	;returns 0 if successful
		ret
MEMFREEBLOCK endp

MEMRESIZEBLOCK proc far pascal wSel:WORD, wSize:WORD 
		mov ax,wSize
		xor dx,dx
		invoke GlobalRealloc, wSel, dx::ax, 0
		and ax,ax
		jz error
		xor ax,ax
		ret
error:
		mov ax,8	;out of memory?
		ret
		
MEMRESIZEBLOCK endp

MEMGETBLOCKSIZE proc far pascal wSel:WORD, lpdwSize:far16 ptr DWORD

		invoke GlobalSize, wSel
		mov cx,ax
		or cx,dx
		jz error
		push ds
		lds bx,lpdwSize
		mov [bx+0],ax
		mov [bx+2],dx
		pop ds
		xor ax,ax
		ret
error:
		mov ax,6	;invalid handle?
		ret
MEMGETBLOCKSIZE endp

;--- returns free memory in DX:AX

MEMQUERYFREEMEM proc far pascal w1:WORD, w2:WORD
		invoke GetFreeSpace, 0
		ret
MEMQUERYFREEMEM endp

dummy33 proc far pascal
		int 3
		ret
dummy33 endp

dummy34 proc far pascal
		int 3
		ret
dummy34 endp

InitSwapping proc far pascal
		int 3
		ret
InitSwapping endp

DoneSwapping proc far pascal
		int 3
		ret
DoneSwapping endp

dummy47 proc far pascal
		int 3
		ret
dummy47 endp

dummy49 proc far pascal
		int 3
		ret
dummy49 endp

dummy50 proc far pascal
		int 3
		ret
dummy50 endp

dummy51 proc far pascal
		int 3
		ret
dummy51 endp

dummy52 proc far pascal
		int 3
		ret
dummy52 endp

WEP proc far pascal wCode:word

		mov ax,1
		ret
WEP endp

LIBMAIN proc far pascal

		mov  ax,1
		ret
LIBMAIN endp

	end LIBMAIN

