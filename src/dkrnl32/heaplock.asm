
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
        include heap32.inc
		include macros.inc

?EXTCHK	equ 0

        .CODE

HeapLock proc public heap:dword

        mov     eax,heap
        test	byte ptr [eax].HEAPDESC.flags, HEAP_NO_SERIALIZE
        jnz     @F
        invoke  WaitForSingleObject,[eax].HEAPDESC.semaphor,INFINITE
@@:        
		@strace	<"HeapLock(", heap, ")=", eax>
        ret
        align 4
HeapLock endp

HeapUnlock proc public heap:dword

        mov     eax,heap
        test	byte ptr [eax].HEAPDESC.flags, HEAP_NO_SERIALIZE
        jnz     @F
        invoke  ReleaseSemaphore,[eax].HEAPDESC.semaphor,1,0
@@:        
		@strace	<"HeapUnlock(", heap, ")=", eax>
        ret
        align 4
HeapUnlock endp

HeapCompact proc public heap:dword, flags:dword
        xor     eax,eax
		@strace	<"HeapCompact(", heap, ", ", flags, ")=", eax>
        ret
        align 4
HeapCompact endp

HeapSize proc public heap:dword, flags:dword, pMem:dword
        mov     ecx,pMem
        mov     eax,[ecx-4]
if ?EXTCHK
		sub		eax,4
endif
		@strace	<"HeapSize(", heap, ", ", flags, ", ", pMem, ")=", eax>
        ret
        align 4
HeapSize endp

        end

