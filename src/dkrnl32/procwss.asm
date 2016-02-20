
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

?MINWORKINGSET	equ 100000h
?MAXWORKINGSET	equ 1000000h

		.CODE

;--- the current process pseudo handle may be hard-coded in some apps
;--- it is 7FFFFFFF in win9x (-1 in winxp?)

checkprochandle proc
        .if ((ecx == -1) || (ecx == 7FFFFFFFh))
        	push eax
        	invoke GetCurrentProcess
            mov ecx, eax
            pop eax
        .endif
        ret
        align 4
checkprochandle endp

GetProcessWorkingSetSize proc public hProcess:DWORD, pdwMinimumWorkingSetSize:ptr DWORD, pdwMaximumWorkingSetSize:ptr DWORD

		xor eax, eax
        mov ecx, hProcess
        call checkprochandle
        .if ([ecx].PROCESS.dwType == SYNCTYPE_PROCESS)
			mov ecx, pdwMinimumWorkingSetSize
    	    mov dword ptr [ecx], ?MINWORKINGSET
			mov ecx, pdwMaximumWorkingSetSize
    	    mov dword ptr [ecx], ?MAXWORKINGSET
        	inc eax
        .endif
		@strace <"GetProcessWorkingSetSize(", hProcess, ", ", pdwMinimumWorkingSetSize, ", ", pdwMaximumWorkingSetSize, ")=", eax>
		ret
        align 4

GetProcessWorkingSetSize endp

SetProcessWorkingSetSize proc public hProcess:DWORD, dwMinimumWorkingSetSize:DWORD, dwMaximumWorkingSetSize:DWORD

		xor eax, eax
        mov ecx, hProcess
        call checkprochandle
        .if ([ecx].PROCESS.dwType == SYNCTYPE_PROCESS)
        	inc eax
        .endif
		@strace <"SetProcessWorkingSetSize(", hProcess, ", ", dwMinimumWorkingSetSize, ", ", dwMaximumWorkingSetSize, ")=", eax>
		ret
        align 4

SetProcessWorkingSetSize endp

GetProcessAffinityMask proc public hProcess:DWORD, lpProcessAffinityMask:ptr DWORD, lpSystemAffinityMask:ptr DWORD
		xor eax, eax
        mov ecx, hProcess
        call checkprochandle
        .if ([ecx].PROCESS.dwType == SYNCTYPE_PROCESS)
	        inc eax
		    mov ecx, lpProcessAffinityMask
			mov edx, lpSystemAffinityMask
	        mov [ecx],eax
    	    mov [edx],eax
        .endif
		@strace <"GetProcessAffinityMask(", hProcess, ", ", lpProcessAffinityMask, ", ", lpSystemAffinityMask, ")=", eax>
		ret
        align 4
GetProcessAffinityMask endp

SetProcessAffinityMask proc public hProcess:DWORD, dwProcessAffinityMask:DWORD
		xor eax, eax
        mov ecx, hProcess
        call checkprochandle
        .if ([ecx].PROCESS.dwType == SYNCTYPE_PROCESS)
	        inc eax
        .endif
		@strace <"SetProcessAffinityMask(", hProcess, ", ", dwProcessAffinityMask, ")=", eax>
		ret
        align 4
SetProcessAffinityMask endp

GetProcessTimes proc public hProcess:DWORD, lpft1:ptr FILETIME, lpft2:ptr FILETIME, lpft3:ptr FILETIME, lpft4:ptr FILETIME
		xor eax, eax
        mov ecx, hProcess
        call checkprochandle
		@strace <"GetProcessTimes(", hProcess, ", ", lpft1, ", ", lpft2, ", ", lpft3, ", ", lpft4, ")=", eax, " *** unsupp ***">
		ret
        align 4
GetProcessTimes endp

GetProcessVersion proc public hProcess:DWORD
		xor eax, eax
if ?FLAT        
		mov ecx, hProcess
        and ecx, ecx
        jnz @F
        invoke GetCurrentProcess
        mov ecx, eax
@@:        
        call checkprochandle
        .if ([ecx].PROCESS.dwType == SYNCTYPE_PROCESS)
	        invoke GetModuleHandle,0
	        mov ecx, eax
    	    add ecx, [ecx].IMAGE_DOS_HEADER.e_lfanew
	        mov ax, [ecx].IMAGE_NT_HEADERS.OptionalHeader.MajorOperatingSystemVersion
    	    shl eax, 16
	        mov ax, [ecx].IMAGE_NT_HEADERS.OptionalHeader.MinorOperatingSystemVersion
		.endif
endif
		@strace <"GetProcessVersion(", hProcess, ")=", eax, " *** unsupp ***">
		ret
        align 4
GetProcessVersion endp

SetProcessShutdownParameters proc public dwLevel:dword, dwFlags:dword
		xor eax,eax
		@strace <"SetProcessShutdownParameters(", dwLevel, ", ", dwFlags, ")=", eax, " *** unsupp ***">
        ret
        align 4
SetProcessShutdownParameters endp

		end
