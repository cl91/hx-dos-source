
        .386
if ?FLAT
        .MODEL FLAT, stdcall
else
        .MODEL SMALL, stdcall
endif
		option casemap:none

        include winbase.inc
		include macros.inc
		include dkrnl32.inc

SEMA_WAIT equ 1       ;ein Thread musste warten

        .CODE

CreateSemaphoreA proc security:dword, dwInitCnt:dword, dwMaxCnt:dword,lpName:dword

		.if (lpName)
			invoke KernelHeapFindObject, lpName
			.if (eax)
            	push eax
                invoke SetLastError, ERROR_ALREADY_EXISTS
                pop eax
				jmp done
			.endif
		.endif
        invoke	KernelHeapAllocObject, sizeof SEMAPHORE, lpName
        and     eax,eax
        jz      done
        mov     ecx,dwInitCnt
        mov     edx,dwMaxCnt
		mov		[eax].SYNCOBJECT.dwType, SYNCTYPE_SEMAPHOR
        mov     [eax].SEMAPHORE.dwCurCnt,ecx
        mov     [eax].SEMAPHORE.dwMaxCnt,edx
        xor		ecx,ecx
		.if (lpName)
            lea ecx, [eax + sizeof SEMAPHORE]
		.endif
		mov [eax].SEMAPHORE.lpName, ecx
done:
		@trace <"CreateSemaphoreA(">
        @tracedw security
        @trace <", ">
        @tracedw dwInitCnt
        @trace <", ">
        @tracedw dwMaxCnt
        @trace <", ">
ifdef _DEBUG
		.if (lpName)
	        @trace lpName
        .else
	        @tracedw lpName
        .endif
endif        
        @strace <")=", eax>
        ret
        align 4
CreateSemaphoreA endp

CreateSemaphoreW proc security:dword, dwInitCnt:dword, dwMaxCnt:dword,lpName:ptr WORD

		mov		eax,lpName
        .if (eax)
			call	ConvertWStr
        .endif
        invoke CreateSemaphoreA, security, dwInitCnt, dwMaxCnt, eax
ifdef _DEBUG
		mov edx, lpName
        .if (!edx)
        	mov edx, CStr("NULL")
        .endif
		@strace <"CreateSemaphoreW(", security, ", ", dwInitCnt, ", ", dwMaxCnt, ", ", &edx, ")=", eax>
endif        
        ret
        align 4
CreateSemaphoreW endp

OpenSemaphoreA proc dwDesiredAccess:dword, bInheritHandle:dword, lpName:dword
		invoke KernelHeapFindObject, lpName
		and eax, eax
		jz @exit
		.if ([eax].SYNCOBJECT.dwType == SYNCTYPE_SEMAPHOR)
		.else
			xor eax, eax
        .endif
@exit:        
		@strace <"OpenSemaphoreA(", dwDesiredAccess, ", ", bInheritHandle, ", ", &lpName, ")=", eax>
		ret
        align 4
OpenSemaphoreA endp

ReleaseSemaphore proc semaphor:dword, lReleaseCount:dword, lpPrevCount:dword

		mov		ecx, lReleaseCount
		mov		edx, FALSE
        call	EnterSerialization
        mov     eax,semaphor
        add     ecx, [eax].SEMAPHORE.dwCurCnt
		.if (ecx <= [eax].SEMAPHORE. dwMaxCnt)
			xchg	ecx, [eax].SEMAPHORE.dwCurCnt
			mov edx, TRUE
		.endif
        call	LeaveSerialization
		mov eax, lpPrevCount
		.if (eax)
			mov [eax], ecx
		.endif
		mov eax, edx
;		@strace <"ReleaseSemaphore(", semaphor, ", ", lReleaseCount, ", ", lpPrevCount, ")=", eax)
        ret
        align 4

ReleaseSemaphore endp

        end

