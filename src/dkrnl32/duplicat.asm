
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

        .CODE

CreateSocketHandle proto

;       db "DUPLICAT"	;???

DuplicateHandle proc public uses ebx hSourceProcess:dword,
                                  hSourceHandle:dword,
                                  hTargetProcess:dword,
                                  lpTargetHandle:dword,
                                  dwDesiredAccess:dword,
                                  bInheritHandle:dword,
                                  dwOptions:dword

local	dwCnt:DWORD

		mov  eax,hSourceHandle
		test eax,0FFFF0000h
		jnz  notafile
		mov	dwCnt,-1
		mov  ebx,eax
nexttry:
		mov  ah,45h
		int  21h
		jnc  done
		cmp		ax, 0004
		jnz		error
		inc		dwCnt
		jnz		error
		invoke	SetHandleCount, 255
		jmp		nexttry
error:
		movzx	eax, ax
		invoke	SetLastError, eax
if 0
		mov	edx, lpTargetHandle
		.if (edx)
			mov dword ptr [edx],-1
		.endif
endif
		xor	eax,eax
		jmp	exit
notafile:
		.if ([eax].SYNCOBJECT.dwType == SYNCTYPE_SOCKET)
        	inc [eax].SOCKET.dwRefCnt
        .endif
done:
		mov	edx,lpTargetHandle
		.if (edx)
			mov	[edx],eax
		.endif
ifdef _DEBUG
		mov ecx, eax
endif
		@mov eax,1
exit:
		@strace	<"DuplicateHandle(", hSourceProcess, ", ", hSourceHandle, ", ", hTargetProcess, ", ", lpTargetHandle, ", ", dwDesiredAccess, ", ", bInheritHandle, ", ", dwOptions, ")=", eax, " [", ecx, "]">
		ret

DuplicateHandle endp

       end

