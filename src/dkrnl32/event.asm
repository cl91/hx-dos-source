
;--- implements:
;--- CreateEventA
;--- OpenEventA
;--- SetEvent
;--- ResetEvent
;--- PulseEvent

	.386
if ?FLAT
	.MODEL FLAT, stdcall
else
	.MODEL SMALL, stdcall
endif
	option proc:private
	option casemap:none

	include winbase.inc
	include macros.inc
	include dkrnl32.inc

	.DATA
        
pNamedEvents	dd 0

	.CODE

CreateEventA proc public uses edi esi ebx security:dword,
			bManualReset:dword, bInitialState:dword, lpName:ptr BYTE

	mov eax, sizeof EVENT
	mov ebx, lpName
	.if (ebx && byte ptr [ebx])	;NULL or szNull is allowed
		lea edi, pNamedEvents
		mov esi, [edi]
		.while (esi)
			mov ecx, [esi+4]
			lea ecx, [ecx+sizeof EVENT]
			invoke lstrcmp, ecx, ebx
			.if (!eax)
				invoke SetLastError, ERROR_ALREADY_EXISTS
				mov eax, [esi+4]
				inc [eax].EVENT.bCount
				jmp done
			.endif
			mov edi, esi
			mov esi, [edi]
		.endw
		invoke lstrlen, ebx
		add eax, sizeof EVENT + 1
	.else
		xor ebx,ebx
	.endif
	invoke KernelHeapAlloc, eax
	and eax,eax
	jz done
;;	mov [eax].SYNCOBJECT.dwType, SYNCTYPE_SEMAPHOR
	mov [eax].EVENT.dwType, SYNCTYPE_EVENT
	mov ecx, bManualReset
	and ecx, 1
	shl ecx, 1
	or [eax].EVENT.bFlags,cl
	mov ecx, bInitialState
	and ecx, 1
	or [eax].EVENT.bFlags, cl
;	mov [eax].EVENT.bNamed, 0
	mov [eax].EVENT.bCount, 1
	push eax
	.if (ebx)
		mov [eax-4], offset destructor
		or [eax].EVENT.bFlags, EVNT_NAMED
		lea ecx, [eax+sizeof EVENT]
		invoke	lstrcpy, ecx, ebx
		invoke KernelHeapAlloc, 8
		and eax, eax
		jz done
		mov [edi], eax
		mov dword ptr [eax], 0
		mov ecx, [esp]
		mov [eax+4], ecx
	.endif
	invoke SetLastError, 0
	pop eax
done:
ifdef _DEBUG
	mov ecx,lpName
	.if (!ecx)
		mov ecx, CStr("NULL")
	.endif
endif
	@strace <"CreateEventA(", security, ", ", bManualReset, ", ", bInitialState, ", ", &ecx, ")=", eax>
	ret
	align 4

CreateEventA endp

destructor proc uses esi pThis:DWORD

	xor eax, eax
	mov ecx, pThis
	dec [ecx].EVENT.bCount
	jnz exit
	lea edx, pNamedEvents
	mov esi, [edx]
	.while (esi)
		.if (ecx == [esi+4])
			mov ecx,[esi]
			mov [edx],ecx
			invoke KernelHeapFree, esi
			.break
		.endif
		mov edx, esi
		mov esi, [esi]
	.endw
	@mov eax, 1
exit:
	ret
	align 4

destructor endp

OpenEventA proc public uses esi dwDesiredAccess:DWORD, bInheritHandle:DWORD, lpName:ptr BYTE

	mov esi, pNamedEvents
	.while (esi)
		mov ecx, [esi+4]
		lea ecx, [ecx+sizeof EVENT]
		invoke lstrcmp, ecx, lpName
		.if (!eax)
			mov eax, [esi+4]
			inc [eax].EVENT.bCount
			jmp exit
		.endif
		mov esi, [esi]
	.endw
	xor eax, eax
exit:
	@strace <"OpenEventA(", dwDesiredAccess, ", ", bInheritHandle, ", ", &lpName, ")=", eax>
	ret
	align 4

OpenEventA endp

;--- SetEvent may be called during interrupt time
;--- dont call DOS then! SS is unknown!

SetEvent proc public hEvent:DWORD

	xor eax, eax
	mov ecx, hEvent
	cmp ecx, eax
	jz exit
	cmp [ecx].EVENT.dwType, SYNCTYPE_EVENT
	jnz exit
	bts dword ptr [ecx].EVENT.bFlags, EVNT_SIGNALED_BIT
if ?EVENTOPT
	jc done
	mov eax,[ecx].EVENT.dwThread
	and eax, eax
	jz @F
 if 1
	cmp [eax].THREAD.bPriority, THREAD_PRIORITY_TIME_CRITICAL
	jnz @F
 endif
	call [g_dwBoostProc]
@@:
endif
done:
	@mov eax, 1
exit:
;	@strace <"SetEventA(", hEvent, ")=", eax>
	ret
	align 4

SetEvent endp

;--- set event object to "non-signaled"

ResetEvent proc public hEvent:DWORD

	xor eax, eax
	mov ecx, hEvent
	cmp [ecx].EVENT.dwType, SYNCTYPE_EVENT
	jnz exit
	and [ecx].EVENT.bFlags, not EVNT_SIGNALED
	@mov eax, 1
exit:
	@strace <"ResetEventA(", hEvent, ")=", eax>
	ret
	align 4

ResetEvent endp

PulseEvent proc public uses ebx hEvent:DWORD

	xor eax, eax
	mov ebx, hEvent
	cmp [ebx].EVENT.dwType, SYNCTYPE_EVENT
	jnz exit
	or [ebx].EVENT.bFlags, EVNT_SIGNALED
	xor ecx, ecx
	call [g_dwIdleProc]
	and [ebx].EVENT.bFlags, not EVNT_SIGNALED
	@mov eax, 1
exit:
	@strace <"PulseEventA(", hEvent, ")=", eax>
	ret
	align 4

PulseEvent endp

	end

