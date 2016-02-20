
;--- source of HX\Lib16\mshelp.obj
;--- required to make HX 16bit MZ binaries compatible
;--- with VC 1.5 C runtime (SLIBCEW.LIB)
;--- in fact some of the exports found in DPMILD16.EXE are recoded here

		.286

_TEXT 	segment word public 'CODE'
_TEXT 	ends
WINSEG	segment word public 'CODE'
WINSEG	ends

CGROUP	group _TEXT,WINSEG

@return	macro xx
ifnb <xx>
		ret xx
else
		ret
endif        
        endm

pLocalHeap	equ 6	;at DS:[6] pointer to local heap
pStackTop	equ 10	;at DS:[10]
pStackMin	equ 12	;at DS:[12]
pStackBot	equ 14	;at DS:[14]

externdef __growseg:near


_DATA	segment word public 'DATA'
extrn	__environ:word
extrn	__acfinfo:word
_DATA	ends

DGROUP	group _DATA

	public	__setenvp
    
_TEXT	segment

	extrn	__myalloc:near

	assume DS:DGROUP

__setenvp:
		push	BP
		mov	BP,SP
		push	DS
		call	far ptr GETDOSENVIRONMENT
		or	AX,AX
		je	L10
		mov	DX,0
L10:		mov	BX,DX
		mov	ES,DX
		xor	AX,AX
		xor	SI,SI
		xor	DI,DI
		mov	CX,0FFFFh
		or	BX,BX
		je	L2F
		cmp	byte ptr ES:[00h],0
		je	L2F
L29:		repne scasb
		inc	SI
		scasb
		jne	L29
L2F:		mov	AX,DI
		inc	AX
		and	AL,0FEh
		inc	SI
		mov	DI,SI
		shl	SI,1
		mov	CX,9
		call	__myalloc
		push	AX
		mov	AX,SI
		call	__myalloc
		mov	__environ,AX
		push	ES
		push	DS
		pop	ES
		pop	DS
		mov	CX,DI
		mov	BX,AX
		xor	SI,SI
		pop	DI
		dec	CX
		jcxz	L7C
L56:		mov	AX,[SI]
		cmp	AX,SS:__acfinfo
		jne	L6F
		push	CX
		push	SI
		push	DI
		mov	DI,offset DGROUP:__acfinfo
		mov	CX,6
		repz cmpsw
		pop	DI
		pop	SI
		pop	CX
		je	L74
L6F:		mov	ES:[BX],DI
		inc	BX
		inc	BX
L74:		lodsb
		stosb
		or	AL,AL
		jne	L74
		loop	L56
L7C:		mov	ES:[BX],CX
		pop	DS
		pop	BP
		ret

_TEXT	ends

WINSEG	segment

GetDOSEnvironment proc far pascal
		mov		ah,51h
        int		21h
        mov		es,bx
		mov 	dx,es:[2Ch]
		xor 	ax,ax
		ret
GetDOSEnvironment endp

UnlockSegment proc far pascal uSegment:word
UnlockSegment endp

LockSegment proc far pascal uSegment:word

		mov 	ax,uSegment
		ret
        
LockSegment endp

IsTaskLocked proc far pascal
		xor 	ax,ax
		ret
IsTaskLocked endp

FatalAppExit proc far pascal pszText:dword
		lds dx,pszText
        mov ah,9
        int 21h
		jmp FatalExit
FatalAppExit endp

FatalExit proc far pascal
		mov 	ax,4CFFh
		int 	21h
FatalExit endp

GetVersion proc far pascal
		mov 	ax,0A03h
		mov 	dx,0
		xchg	dh,dl
		ret
GetVersion endp

WaitEvent proc far pascal hTask:word
		ret
WaitEvent endp        

;*****************************
;*** Local Heap functions  ***
;*****************************

LocalInit proc far pascal uSegment:word, uStart:word, uEnd:word

        mov		ax,uSegment
        mov		cx,uStart
        mov		dx,uEnd
		and 	ax,ax
		jnz 	@F
		mov 	ax,ds
@@:
		cmp 	dx,4
		jb		LocalInit_err
		lar 	bx,ax
		jnz 	LocalInit_err
		jcxz	LocalInit_1
		cmp 	dx,cx
		jb		LocalInit_err
		jmp 	LocalInit_2
LocalInit_1:
		lsl 	bx,ax
		inc 	bx
		mov 	cx,dx
		mov 	dx,bx
		sub 	bx,cx
		mov 	cx,bx
LocalInit_2:
		push	ds
		mov 	ds,ax
		mov 	ds:[pLocalHeap],cx
		add 	word ptr ds:[pLocalHeap],2
		mov 	bx,cx
		sub 	dx,2
		mov 	[bx],dx
		or		byte ptr [bx],1
		mov 	bx,dx
		mov 	[bx],dx
		mov 	ax,1
		pop 	ds
		jmp 	LocalInit_ex
LocalInit_err:
		xor 	ax,ax
LocalInit_ex:
		ret
LocalInit endp

;--- called by LocalAlloc
;*** freies speicherstueck auf heap suchen	 ***
;*** inp: DS=heapsegm, BX= ^heapdesc, CX=size ***

__searchseg proc
		inc 	CX
		and 	CL,0FEh
__searchseg3:
		mov 	ax,[bx]
		cmp 	ax,bx
        jbe     __searchseg5        ;error, heap zuende
		xor 	dx,dx
        test    al,1                ;frei?
        jz      __searchseg1        ;falls nicht -> weiter
		mov 	dx,ax
        sub     dx,bx               ;laenge ermitteln
        sub     dx,3                ;korrektur
		cmp 	cx,dx
        jbe     __searchseg2        ;stueck ist gross genug
        push    si                  ;falls naechstes stueck auch frei
		and 	al,0FEh
		mov 	si,ax
		mov 	ax,[si]
		test	al,1
		jz		short @F
		mov 	[bx],ax
		mov 	si,bx
@@:
		mov 	ax,si
		pop 	si
__searchseg1:
		mov 	bx,ax
		jmp 	__searchseg3
__searchseg5:
		stc
		ret
__searchseg2:						;freien eintrag gefunden
		mov 	dx,ax
		lea 	ax,[bx+2]
		jz		__searchseg4		;laenge stimmt genau
		add 	cx,ax
		mov 	[bx],cx 			;neuen pointer abspeichern
		push	bx
		mov 	bx,cx
		mov 	[bx],dx 			;und hier auch
		pop 	bx
__searchseg4:
		and 	byte ptr [bx],0FEh
		ret
__searchseg endp

LocalAlloc proc far pascal uses si di uFlags:word, uBytes:word

		mov 	cx,uBytes
		cmp 	CX,0FFE8h
		ja		LocalAlloc1
		mov 	BX,ds:[pLocalHeap]
		and 	bx,bx
		jz		LocalAlloc1
		sub 	bx,2
		call	__searchseg
		jnc 	LocalAlloc2			;ok, eintrag gefunden
		call	__growseg
		jc		LocalAlloc1			;heap nicht verweiterbar, fehler
		mov 	BX,ds:[pLocalHeap]
		sub 	bx,2
		call	__searchseg
		jc		LocalAlloc1			;reichte erweiterung aus?
		mov 	cx,uFlags
		test	cl,40h
		jz		LocalAlloc2
		push	ax
		push	di
		mov 	cx,uBytes
		mov 	di,ax
		push	ds
		pop 	es
		xor 	ax,ax
		shr 	cx,1
		cld
		rep 	stosw
		adc 	cl,0
		rep 	stosb
		pop 	di
		pop 	ax
		jmp 	LocalAlloc2
LocalAlloc1:
		xor 	AX,AX
LocalAlloc2:
		ret
LocalAlloc endp

LocalFree proc far pascal handle:WORD

		mov		ax,handle
		mov 	bx,ds:[pLocalHeap]
		and 	bx,bx
		jz		LocalFree_err
		sub 	bx,2
		sub 	ax,2
LocalFree_2:
		cmp 	ax,bx
		jz		LocalFree_3
		mov 	cx,[bx]
		and 	cl,0FEh
		cmp 	cx,bx
		mov 	bx,cx
		jnz 	LocalFree_2
LocalFree_err:
		xor 	ax,ax
		jmp 	LocalFree_ex
LocalFree_3:
		test	byte ptr [bx],1
		jnz 	LocalFree_err
		or		byte ptr [bx],1
LocalFree_ex:
		ret
LocalFree endp

LocalReAlloc proc far pascal
		xor 	ax,ax
		@return 6
LocalReAlloc endp
        
LocalUnlock proc far pascal
LocalUnlock endp

LocalLock proc far pascal
		pop 	cx
		pop 	dx
		pop 	ax
		push	dx
		push	cx
		retf
LocalLock endp

LocalSize proc far pascal wHandle:word
		mov		ax,wHandle
		and 	ax,ax
		jz		localsize_ex
		mov 	bx,ax
		mov 	ax,[bx-2]
		sub 	ax,bx
localsize_ex:
		ret
LocalSize endp

LocalCompact proc far pascal
		mov 	ax,ds:[pLocalHeap]
		and 	ax,ax
		jz		localcompact_ex
		sub 	ax,2
		mov 	bx,ax
		xor 	cx,cx
localcompact_3:
		mov 	ax,[bx]
		cmp 	ax,bx
		jz		localcompact_2
		test	al,1
		jz		localcompact_1
		and 	al,0FEh
		cmp 	ax,cx
		jc		localcompact_1
		mov 	cx,ax
localcompact_1:
		mov 	bx,ax
		jmp 	localcompact_3
localcompact_2:
		mov 	ax,cx
localcompact_ex:
		@return 2
LocalCompact endp


GlobalSize proc far pascal
        pop     bx
        pop     cx
        pop     ax
        push    cx
        push    bx
		lsl 	ax,ax
        jc      @F
		add 	ax,1
		adc 	dx,0
        jmp     exit
@@:
		xor 	ax,ax
		cwd
exit:
        @return
GlobalSize endp

GlobalDOSAlloc proc far pascal
        pop bx
        pop cx
        pop ax
        pop dx
        push cx
        push bx
		mov 	cl,al
		shr 	ax,4
		shl 	dx,12
		or		ax,dx
		test	cl,0Fh
        jz      @F
		inc 	ax
@@:
		mov 	bx,ax
		mov 	ax,0100h		;alloc dos memory
		int 	31h
		xchg	ax,dx
		jnc 	@F
		xor 	ax,ax
@@:
        @return
GlobalDOSAlloc endp

GetWinFlags proc far pascal
		mov 	ax,0
		ret
GetWinFlags endp

DebugBreak proc far pascal
		int 	3
		ret
DebugBreak endp

;--- FreeSelector(WORD)

FreeSelector proc far pascal
        pop     cx
        pop     dx
        pop     bx
        push    dx
        push    cx
		mov 	ax,0001
		int 	31h
		mov 	ax,0000
		jnc 	@F
		mov 	ax,bx
@@:
        ret
FreeSelector endp

Dos3Call proc far pascal
		int 	21h
		ret
Dos3Call endp

GetCurrentTask proc far pascal
		mov ah,51h
        int 21h
        mov ax,bx
		ret
GetCurrentTask endp

GetCurrentPDB proc far pascal
		mov ah,51h
        int 21h
        mov ax,bx
		ret
GetCurrentPDB endp

GlobalLock proc far pascal
        pop cx
        pop bx
        pop dx
        push bx
        push cx
		xor 	ax,ax
        @return
GlobalLock endp

GlobalUnlock proc far pascal
        pop cx
        pop dx
        pop ax
        push dx
        push cx
        @return
GlobalUnlock endp


GlobalAlloc proc far pascal flags:word, dwSize:dword

		mov     dx, word ptr dwSize+2
		mov     ax, word ptr dwSize+0
		push	ax
		mov 	cx,4
@@:
		shr 	dx,1
		rcr 	ax,1
		loop	@B
		pop 	cx
		and 	dx,dx
		jnz 	globalallocerr		;maximum is 1 MB in 16 bit version
		test	cl,0Fh
		jz		@F
		inc 	ax
@@:
		mov 	bx,ax
		mov 	ah,48h			   ;ueber DOS allokieren, da sonst
		int 	21h 			   ;handleverwaltung notwendig (ebx paras)
		jc		globalallocerr
        ret
globalallocerr:
		xor		ax,ax
		ret
GlobalAlloc	endp

GlobalReAlloc proc far pascal uses si hMem:WORD, dwNewsize:DWORD, uiMode:WORD 

		mov si, hMem
        mov dx, word ptr dwNewsize+2
        mov ax, word ptr dwNewsize+0

		mov 	es,hMem
		push	ax
		mov 	cx,4
@@:
		shr 	dx,1
		rcr 	ax,1
		loop	@B
		pop 	cx
		and 	dx,dx
        jnz     globalreallocerr
		test	cl,0Fh
		jz		@F
		inc 	ax
@@:
		mov 	bx,ax
		push	es
		mov 	ah,4Ah
		int 	21h
		pop 	ax
		jnc 	exit
        
globalreallocerr:
		xor 	ax,ax
exit:
		ret
        
GlobalReAlloc endp

GlobalFree proc far pascal
        pop cx
        pop dx
        pop es
        push dx
        push cx
		mov 	ah,49h
		int 	21h
        @return
GlobalFree endp

GlobalUnfix proc far pascal
GlobalUnfix endp
GlobalFix proc far pascal
		@return 2
GlobalFix endp

GlobalHandle proc far pascal
        pop cx
        pop dx
        pop ax
        push dx
        push cx
		mov 	dx,ax
        @return
GlobalHandle endp


;*** InitTask ***
;*** register values on entry:
;*** BX: Stacksize (16 bit version only)
;*** CX: Heapsize (16 bit version only)
;*** DI: Instance handle
;*** SI: 
;*** ES: PSP
;*** DS: DGROUP
;*** SS: DGROUP
;*** SP: top of Stack
;*** Out: CX=stack limit
;*** SI,DI=Instance Handle
;*** ES=PSP
;*** ES:BX=CmdLine (DOS format)
;*** DX=cmdShow (not used)

externdef _end:abs

InitTask proc far pascal uses ds

        mov		ax,sp
        add		ax,3*2
		cmp 	word ptr ds:[4],5
		jnz 	@F
		mov 	ds:[pStackBot],ax
		mov 	ds:[pStackMin],ax
        mov		cx,0
        sub		cx, ax
		mov 	ax,_end				;top stack
		add 	ax,60h
		mov 	ds:[pStackTop],ax
        invoke  LocalInit, ds, 0, cx
@@:
		mov		ah,51h
        int		21h
        mov		es,bx
        mov		bx,80h
		mov		cx,sp
        add		cx,3*2
        sub		cx,_end
        mov		di,ss
		xor 	si,si
        mov		ax,1
		ret

InitTask endp

;--- GetModuleFileName(hInst,lpszFileName,maxlen)

GetModuleFileName   proc far pascal uses si di hInst:word, lpszFileName:far ptr BYTE, uMax:word

		mov		ah,51h
        int		21h
        mov		es,bx
        mov		es,es:[002Ch]
        xor		di,di
        or		cx,-1
        mov		al,0
        cld
@@:        
        repnz	scasb
        scasb
        jnz		@B
        add		di,2
        mov		si,di
        push	ds
        push	es
        pop		ds
        les		di, lpszFileName
        mov		cx, uMax
@@:
		lodsb
		stosb
		and 	al,al
		loopnz	@B
		pop		ds
		mov 	ax,uMax
		sub 	ax,cx
		dec 	ax
		ret
GetModuleFileName   endp

WINSEG	ends
		
		end
        