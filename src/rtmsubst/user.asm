
;--- simple 16-bit USER emulation for DOS

		.286
        .model small
		.386
        
		.code

FILE struct
bufptr	dd ?
maxbuf	dw ?
buf2	dd ?
flags	db ?
res1	db ?
FILE ends

_output proto far c :far ptr FILE, :far16 ptr, :far16 ptr

g_bMouse db 0

		align 2

INITAPP proc far pascal hInst:word
        mov  ax,1
        ret
INITAPP endp

;--- void GetCursorPos(far16 ptr lpPoint)

GETCURSORPOS proc far pascal uses ds lpPoint:far ptr DWORD

		.if (g_bMouse)
	        mov ax,3
    	    int 33h
			lds bx,lpPoint
	        mov [bx+0],cx
    	    mov [bx+2],dx
        .endif
        ret
        
GETCURSORPOS endp

;--- void SetCursorPos(WORD x, WORD y)

SETCURSORPOS proc far pascal x:word, y:word

		.if (g_bMouse)
			mov cx,x
			mov dx,y
			mov ax,4  
    	    int 33h
        .endif
        ret
SETCURSORPOS endp

WINDOWFROMPOINT proc far pascal lpPoint:dword
        xor ax,ax
        ret
WINDOWFROMPOINT endp

GETSYSTEMMETRICS proc far pascal wIndex:word
        xor ax,ax
        ret
GETSYSTEMMETRICS endp

;--- the following required by Borland Powerpack

MESSAGEBOX proc far pascal uses ds si hWnd:word, lpMsg:DWORD, lpCap:DWORD, uParm:WORD

		lds  si, lpMsg
        cld
nextitem:        
        lodsb
        and al,al
        jz done
        call printchar
        jmp nextitem
done:
		mov al,13
        call printchar
        mov al,10
        call printchar
        mov  ax,1
        ret
printchar:
		mov dl,al
        mov ah,2
        int 21h
		retn
MESSAGEBOX endp

ENUMTASKWINDOWS proc far pascal hTask:word, wndenmproc:DWORD, lParam:dword
		xor ax,ax
        ret
ENUMTASKWINDOWS endp

GETDESKTOPWINDOW proc far pascal
		xor ax,ax
        ret
GETDESKTOPWINDOW endp

GETTICKCOUNT proc far pascal
		push ds
        push 0040h
        pop ds
        push eax
        mov eax, ds:[006Ch]
        mov ecx, 55
        mul ecx
        push eax
        pop ax
        pop dx
        pop ds
        ret
GETTICKCOUNT endp

ANSILOWER proc far pascal uses ds si lpsz:far ptr BYTE
		mov ax, word ptr lpsz+0
		mov dx, word ptr lpsz+2
        and dx,dx
        jz  ischar
        mov ds,dx
        mov si,ax
        cld
nextitem:        
        lodsb
        and al,al
        jz done
        call convert
        mov [si-1],al
        jmp nextitem
ischar:
		call convert
done:
        ret
        
convert:
		cmp al,'A'
        jb nochar
        cmp al,'Z'
        ja nochar
        or al,20h
nochar:        
		retn
ANSILOWER endp

ANSIUPPER proc far pascal uses ds si lpsz:far ptr BYTE
		mov ax, word ptr lpsz+0
		mov dx, word ptr lpsz+2
        and dx,dx
        jz  ischar
        mov ds,dx
        mov si,ax
        cld
nextitem:        
        lodsb
        and al,al
        jz done
        call convert
        mov [si-1],al
        jmp nextitem
ischar:
		call convert
done:
        ret
        
convert:
		cmp al,'a'
        jb nochar
        cmp al,'z'
        ja nochar
        and al,not 20h
nochar:        
		retn
ANSIUPPER endp

LOADSTRING proc far pascal hInst:WORD, idResource:WORD, lpszBuffer:far ptr BYTE, cbBuffer:WORD
		xor ax,ax
		retf
LOADSTRING endp

LSTRCMP	proc far pascal uses ds si di strg1:far16, strg2:far16

        lds     si,strg1
        les     di,strg2
        xor     ax,ax
        mov     cx,-1
        repne   scasb
        not     cx
        sub     di,cx
        repz    cmpsb
        je      @F
        sbb     AX,AX
        sbb     AX,-1
@@:
        ret
LSTRCMP endp


wsprintf proc far c buffer:far16 ptr,formstr:far16 ptr,nextparms:VARARG

local   _file:FILE

        push    ds
        mov     AX,word ptr buffer+0
        mov     DX,word ptr buffer+2
        mov     word ptr _file.bufptr+0,AX
        mov     word ptr _file.bufptr+2,DX
        mov     word ptr _file.buf2+0,AX
        mov     word ptr _file.buf2+2,DX
        mov     _file.maxbuf,07FFFh
        mov     _file.flags,042h
        invoke	_output, addr _file, formstr, addr nextparms

        lds     BX,_file.bufptr
        mov     byte ptr [BX],0
        pop     ds
        ret

wsprintf endp

WEP proc far pascal wCode:word

		mov ax,1
        ret
WEP endp

LIBMAIN proc far pascal

		mov  bl,33h
        mov  ax,200h
        int  31h
        mov  ax,cx
        or   ax,dx
        jz   nomouse
        mov  bx,cs
        mov  ax,000Ah
        int  31h
        jc   nomouse
        push ds
        mov  ds,ax
        assume ds:_TEXT
        mov  g_bMouse,1
        pop  ds
        assume ds:nothing
        mov  bx,ax
        mov  ax,1
        int  31h
nomouse:        
        mov  ax,1
        ret
LIBMAIN endp

	end LIBMAIN

