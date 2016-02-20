
	.386
if ?FLAT
	.MODEL FLAT, stdcall
else
	.MODEL SMALL, stdcall
endif
	option casemap:none
	option proc:private

	include winbase.inc
	include dkrnl32.inc
	include macros.inc

?USETICKCNT	equ 1	;1=use GetTickCount for delays > ?TIMESLICE*2
?TIMERCACHE	equ 2	;use x timers as cache

	.DATA

if ?TIMERCACHE        
g_Timer	TIMER ?TIMERCACHE dup (<<SYNCTYPE_TIMER>,-1>)
endoftimers label byte
endif

	.CODE

;--- more accurate wait if interval is < 110 ms
;--- inp: ecx=time to wait in ms

_Wait proc
	mov esi, ecx
if ?TIMERCACHE
	cli
	mov ebx, offset g_Timer
nextitem:
	cmp [ebx].TIMER.hThread,0
	jz itemfound
	lea ebx, [ebx+sizeof TIMER]
	cmp ebx, offset endoftimers
	jnz nextitem
	sti
endif
	xor ecx, ecx
	invoke CreateWaitableTimer, ecx, ecx, ecx
	and eax,eax
	jz error
	mov ebx, eax
	push offset delobj
if ?TIMERCACHE
	jmp @F
	align 4
itemfound:
	mov [ebx].TIMER.hThread,-1
	sti
@@:
endif
	mov eax, esi
	mov ecx, 1000*10	;convert ms -> 100 ns units
	mul ecx
	neg eax
	cdq
	push edx
	push eax
	@loadesp edx
	xor ecx, ecx
	invoke SetWaitableTimer, ebx, edx, ecx, ecx, ecx, ecx
	add esp,2*4

;--- do NOT call WaitForSingleObject (which would call Sleep(0))
;	 invoke WaitForSingleObject, ebx, 1000	;timeout 1000 ms

	.while ([ebx].TIMER.bSignaled == FALSE)
		.if (g_bDispatchFlags & FTI_INIT)
			or ecx, TF_WAITING
			call g_dwIdleProc
		.endif
	.endw
	invoke CancelWaitableTimer, ebx
error:
exit:
	@strace <"_Wait(", esi, ")=", eax>
	ret
	align 4
delobj:
	invoke	CloseHandle, ebx
	retn
	align 4

_Wait endp

Sleep proc public dwInterval:dword

ifdef _DEBUG
	.if (g_dwDebugFlags & DBGF_WAIT)
		@strace <"Sleep(", dwInterval, ") esp=", esp>
	.endif
endif
	mov ecx,dwInterval
	jecxz noint
if ?USETICKCNT
	cmp ecx, ?TIMESLICE*2
	jnc @F
endif
	push ebx
	push esi
	call _Wait
	pop esi
	pop ebx
	jmp done
	align 4
if ?USETICKCNT
@@:
	push esi
	invoke GetTickCount
	mov esi, eax
	.repeat
		or ecx, TF_WAITING
		call g_dwIdleProc
		invoke GetTickCount
		sub eax, esi
	.until (sdword ptr eax >= dwInterval)	;using signed cmp is a hack
	pop esi
	jmp done
	align 4
endif
noint:
	or ecx, TF_WAITING
	call g_dwIdleProc
done:
ifdef _DEBUG
	mov eax,[g_hCurThread]
	.if (g_dwDebugFlags & DBGF_WAIT)
		@strace <"Sleep(", dwInterval, ")=", eax , " esp=", esp>
	.endif
endif
	ret
	align 4

Sleep endp

SleepEx proc public dwInterval:dword, bAlertable:dword
	invoke Sleep, dwInterval
ifdef _DEBUG
	.if (g_dwDebugFlags & DBGF_WAIT)
		@strace <"SleepEx(", dwInterval, ", ", bAlertable, ")=", eax>
	.endif
endif
	ret
	align 4

SleepEx endp

	end
