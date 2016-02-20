
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

ife ?FLAT
;extern  __callkernelinit@0:near32
;extern  __callkernelterm@0:near32
endif


        .CODE

ExitProcess proc public dwRC:dword

		@strace	<"ExitProcess(", dwRC, ")">
ife ?HOOKINT21        
        invoke	GetCurrentProcess
        or  	byte ptr [eax].PROCESS.wFlags, PF_TERMINATING

;-- run the exit code on the application stack        
;-- this is the one stack valid all the time and
;-- it is released by DPMILD32 *after* all dlls are unloaded
        
        mov		edx, [eax].PROCESS.hThread
        mov		ecx, [edx].THREAD.dwStackTop
        jecxz	@F
        mov		esp, ecx
@@:        
endif
        mov     al,byte ptr dwRC
        mov     ah,4Ch
        int     21h
        ret
ExitProcess endp

end

