
        .386
if ?FLAT
        .MODEL FLAT, stdcall
else
        .MODEL SMALL, stdcall
endif
		option proc:private
        option casemap:none

        include winbase.inc
        include dkrnl32.inc
		include macros.inc

        .CODE

;--- bInitialOwner == 1: mutex is owned by current thread
;--- bInitialOwner == 0: mutex is unowned

CreateMutexA proc public security:dword, bInitialOwner:dword, lpName:ptr BYTE

		.if (lpName)
			invoke KernelHeapFindObject, lpName
			.if (eax)
            	push eax
                invoke SetLastError, ERROR_ALREADY_EXISTS
                pop eax
				jmp done
			.endif
		.endif
        
        invoke	KernelHeapAllocObject, sizeof MUTEX, lpName
        and     eax,eax
        jz      done
		mov		[eax].SYNCOBJECT.dwType, SYNCTYPE_MUTEX   
        mov     [eax].MUTEX.dwCnt,0
        .if (bInitialOwner)
        	push eax
        	invoke _GetCurrentThread
            mov ecx, eax
            pop eax
            mov [eax].MUTEX.dwOwner, ecx
            inc [eax].MUTEX.dwCnt
        .endif
        xor		ecx,ecx
		.if (lpName)
            lea ecx, [eax + sizeof MUTEX]
		.endif
		mov [eax].MUTEX.lpName, ecx
done:
		@trace <"CreateMutexA(">
        @tracedw security
        @trace <", ">
        @tracedw bInitialOwner
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
CreateMutexA endp

CreateMutexW proc public security:dword, bInitialOwner:dword, lpName:ptr WORD

		mov		eax,lpName
        .if (eax)
			call	ConvertWStr
        .endif
		invoke	CreateMutexA, security, bInitialOwner, eax
		@strace <"CreateMutexW()=", eax>
        ret
        align 4
CreateMutexW endp

OpenMutexA proc public dwDesiredAccess:dword, bInheritHandle:dword, lpName:dword

		invoke KernelHeapFindObject, lpName
		and eax, eax
		jz @exit
		.if ([eax].SYNCOBJECT.dwType == SYNCTYPE_MUTEX)
;--- todo
		.else
			xor eax, eax
        .endif
@exit:        
		@strace <"OpenMutexA(", dwDesiredAccess, ", ", bInheritHandle, ", ", lpName, ")=", eax>
		ret
        align 4
OpenMutexA endp

OpenMutexW proc public dwDesiredAccess:dword, bInheritHandle:dword, lpName:ptr WORD

		mov eax, lpName
        call ConvertWStr
        invoke OpenMutexA, dwDesiredAccess, bInheritHandle, eax
		@strace <"OpenMutexW(", dwDesiredAccess, ", ", bInheritHandle, ", ", lpName, ")=", eax>
		ret
        align 4
        
OpenMutexW endp

ReleaseMutex proc public hMutex:dword

        invoke _GetCurrentThread
        mov ecx, hMutex
        jecxz error
        cmp eax, [ecx].MUTEX.dwOwner
        jnz error
        dec [ecx].MUTEX.dwCnt
        jnz @F
        mov [ecx].MUTEX.dwOwner, 0
@@:        
		@mov eax, 1
exit:
		@strace <"ReleaseMutex(", hMutex, ")=", eax>
        ret
error:
		xor eax, eax
        jmp exit
        align 4

ReleaseMutex endp

        end

