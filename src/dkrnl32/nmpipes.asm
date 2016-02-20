
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

if 1
CreateNamedPipeA proc public lpName:ptr BYTE, dwOpenMode:dword, dwPipeMode:dword,
			nMaxInstances:dword, nOutBufferSize:dword, nInBufferSize:dword, nDefaultTimeOut:dword,
            lpSecurity:ptr
		xor eax, eax
		@strace	<"CreateNamedPipeA(",  lpName, ", ", dwOpenMode, ", ", dwPipeMode, ", ", nMaxInstances, ", ", nOutBufferSize, ", ", nInBufferSize, ", ", nDefaultTimeOut, ")=", eax>
		ret
        align 4
CreateNamedPipeA endp
endif

PeekNamedPipe proc public handle:dword,lpbuffer:dword,
                           nsize:dword,lpBytesRead:ptr dword,pTotalBytes:dword,
                           pBytesLeft:dword
local	dwCurPos:DWORD
local	dwRead:DWORD

		.if (!lpBytesRead)
        	lea eax, dwRead
            mov lpBytesRead, eax
        .endif

		invoke	SetFilePointer, handle, 0, 0, FILE_CURRENT
        mov		dwCurPos, eax
        .if (eax == -1)
	        xor eax,eax
        	jmp error
        .endif
        .if (lpbuffer && nsize)
        	invoke ReadFile, handle, lpbuffer, nsize, lpBytesRead, 0
        .endif
        .if (pTotalBytes)
			invoke	SetFilePointer, handle, 0, 0, FILE_END
            sub eax, dwCurPos
            mov ecx, pTotalBytes
            mov [ecx],eax
        .endif
		invoke	SetFilePointer, handle, dwCurPos, 0, FILE_BEGIN
        @mov eax, 1
error:        
		@strace	<"PeekNamedPipe(", handle, ", ", lpbuffer, ", ", nsize, ", ", lpBytesRead, ", ", pTotalBytes, ", ", pBytesLeft, ")=", eax>
        ret
        align 4
PeekNamedPipe endp

GetNamedPipeHandleStateA proc public handle:dword, lpdw1:ptr dword, lpdw2:ptr dword, lpdw3:ptr dword, lpdw4:ptr dword, x6:dword, x7:dword

        xor     eax,eax
		@strace	<[ebp+4],": GetNamedPipeHandleState(", handle, ", ", lpdw1, ", ", lpdw2, ", ", lpdw3, ", ", lpdw4, ", ", x6, ", ", x7, ")=", eax, " *** unsupp ***">
		ret
        align 4
GetNamedPipeHandleStateA endp

SetNamedPipeHandleState proc public handle:dword, lpdw1:ptr dword, lpdw2:ptr dword, lpdw3:ptr dword

        xor     eax,eax
		@strace	<[ebp+4],": SetNamedPipeHandleState(", handle, ", ", lpdw1, ", ", lpdw2, ", ", lpdw3, ")=", eax, " *** unsupp ***">
		ret
        align 4
SetNamedPipeHandleState endp

GetNamedPipeInfo proc public handle:dword, lpFlags:ptr dword, lpOutBufferSize:ptr dword, lpInBufferSize:ptr dword, lpMaxInstances:ptr dword

        xor     eax,eax
        mov     ecx, lpFlags
        jecxz	@F
        mov		[ecx],eax
@@:        
        mov     ecx, lpOutBufferSize
        jecxz	@F
        mov		[ecx],eax
@@:        
        mov     ecx, lpInBufferSize
        jecxz	@F
        mov		[ecx],eax
@@:        
        mov     ecx, lpMaxInstances
        jecxz	@F
        mov		[ecx],eax
@@:        
		@strace	<[ebp+4],": GetNamedPipeInfo(", handle, ", ", lpFlags, ", ", lpOutBufferSize, ", ", lpInBufferSize, ", ", lpMaxInstances, ")=", eax, " *** unsupp ***">
		ret
        align 4
GetNamedPipeInfo endp

WaitNamedPipeA proc public handle:dword, dw1:ptr dword
        xor     eax,eax
		@strace	<[ebp+4],": WaitNamedPipeA(", handle, ", ", dw1, ")=", eax, " *** unsupp ***">
		ret
        align 4
WaitNamedPipeA endp

ConnectNamedPipe proc public hNamedPipe:DWORD, lpOverlapped:ptr
		xor eax, eax
		@strace	<"ConnectNamedPipe(", hNamedPipe, ", ", lpOverlapped, ")=", eax, " *** unsupp ***">
        ret
        align 4
ConnectNamedPipe endp

DisconnectNamedPipe proc public hNamedPipe:DWORD
		xor eax, eax
		@strace	<"DisconnectNamedPipe(", hNamedPipe, ")=", eax, " *** unsupp ***">
        ret
        align 4
DisconnectNamedPipe endp

	end
