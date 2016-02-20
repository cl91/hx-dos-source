
        .386
if ?FLAT
        .MODEL FLAT, stdcall
else
        .MODEL SMALL, stdcall
endif
		option casemap:none

        include winbase.inc
        include macros.inc


        .CODE

IsDebuggerPresent	proc	;dont log this call!!!
        mov ax, 004Fh
        int 41h
        cmp ax,0F386h
        @mov eax,0
        jnz @F
        inc eax
@@:        
		ret
        align 4
IsDebuggerPresent	endp

WaitForDebugEvent proc lpDebugEvent:ptr, dwMilliseconds:DWORD

		xor eax, eax
        ret
        align 4

WaitForDebugEvent endp

ContinueDebugEvent proc dwProcessId:DWORD, dwThreadId:DWORD, dwContinueStatus:DWORD 

		xor eax, eax
        ret
        align 4

ContinueDebugEvent endp

GetThreadSelectorEntry	proc hThread:DWORD, dwSelector:DWORD, lpSelectorEntry:ptr
		xor eax, eax
        ret
        align 4
GetThreadSelectorEntry	endp

DebugActiveProcess	proc hProcess:DWORD
		xor eax, eax
        ret
        align 4
DebugActiveProcess	endp

end

