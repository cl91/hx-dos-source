
        .386
if ?FLAT
        .MODEL FLAT, stdcall
else
        .MODEL SMALL, stdcall
endif
        option casemap:none
		option proc:private

?USEDOSIDLE		equ 0		;problems in WinXP
?USEKERNELIDLE	equ 0

        include winbase.inc
        include dkrnl32.inc
        include dpmi.inc

?SAVEALL equ 0

@pushregs macro
if ?SAVEALL
		pushad
        push ds
        push es
        push fs
        push gs
else
;		push ebx
endif
		endm

@popregs macro
if ?SAVEALL
		pop gs
        pop fs
        pop es
        pop ds
        popad
else
;		pop  ebx
endif
		endm

        .DATA

g_dwIdleProc 		dd offset _GiveupTimeSlice
g_bDispatchFlags	db 0

        .CODE

_GiveupTimeSlice proc public
if ?USEKERNELIDLE
        mov     ax,1689h
        int     2Fh
else
		@pushregs
        mov     ax,1680h
        int     2Fh
        cmp		al,80h
        jnz		done
if ?USEDOSIDLE
        push    edi
        push    ecx
        sub     esp,34h
        mov     edi,esp
        mov     [edi].RMCS.rSSSP,0
        mov     [edi].RMCS.rFlags,0
        mov     bx,0028h
        xor     cx,cx
        mov     ax,0300h
        int     31h
        add     esp,34h
        pop     ecx
        pop     edi
else
		cmp		cs:[g_bHost], HF_WINNT
        jnz		@F
        mov		ah,01h
        int		16h
@@:        
endif        
done:        
        @popregs        
endif
        ret
_GiveupTimeSlice endp

	end
