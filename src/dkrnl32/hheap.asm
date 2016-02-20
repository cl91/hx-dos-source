
;--- kernel heap procedures

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
		include heap32.inc
		include macros.inc

		option dotname

?KHEAPSIZE	equ 1000h

.BASE$XA      SEGMENT dword public 'DATA'
		DD offset Deinstall
.BASE$XA      ENDS

;--- for MZ support: make sure constructor is executed before all
;--- other runtime initialization.

ife ?FLAT
extern __KERNELINIT:abs
DGROUP  group .BASE$XA
endif

        .DATA

;--- the kernel heap descriptor. 

		dd 0				;a semaphor is a kernel object with possible
							;destructor at offset -4
khsemaphor	SEMAPHORE {{SYNCTYPE_SEMAPHOR},1,1,0}
if ?FREELIST
defaultheap	HEAPDESC {khsemaphor, HEAP_GROWABLE, 0, offset defblock,\
			offset defblock, ?KHEAPSIZE}
else
defaultheap	HEAPDESC {khsemaphor, HEAP_GROWABLE, 0, offset defblock,\
			offset defblock, ?KHEAPSIZE, offset (defblock + ?KHEAPSIZE - 4)}
endif            

hKernelHeap	dd 0

		.data?

;--- the kernel heap is a normal heap which can be accessed
;--- by HeapAlloc, HeapFree, ...

defblock	db ?KHEAPSIZE dup (?)	

		.code

if 1
GetKernelHeap	proc public
		mov eax, hKernelHeap
		ret
        align 4
GetKernelHeap	endp
endif

IsKernelHeapLocked proc public
		xor eax, eax
		mov ecx, hKernelHeap
        mov ecx, [ecx].HEAPDESC.semaphor
        .if (![ecx].SEMAPHORE.dwCurCnt)
        	inc eax
        .endif
		ret
        align 4
IsKernelHeapLocked endp

;--- alloc a kernel heap memory object.
;--- all objects have an optional destructor at offset -4
;--- which is used by KernelHeapFree

KernelHeapAlloc proc public dwBytes:DWORD

		mov eax, hKernelHeap
		.if (!eax)
			mov eax, offset defaultheap
			mov hKernelHeap, eax
			mov ecx, ?KHEAPSIZE - 8 + 1
			mov edx, offset defblock
			mov [edx].FLITEM.dwSize, ecx
			mov [edx].FLITEM.pNext, NULL
            lea ecx,[ecx+edx+3]
			mov dword ptr [ecx], _HEAP_END
			mov [eax].HEAPDESC.last, ecx
			@strace <"init kernel heap, heap desc=", eax, ", start block=", [eax].HEAPDESC.start>
		.endif
		mov ecx, dwBytes
		lea ecx, [ecx+4]
;;		invoke HeapAlloc, eax, 0, ecx
ifdef _DEBUG
       	pushfd
        pop edx
        test dh,2	;interrupts disabled?
        jnz @F
        mov edx, [eax].HEAPDESC.semaphor
        .if (![edx].SEMAPHORE.dwCurCnt)	;kernelheap locked?
            int 3
        .endif
@@:            
endif
		invoke HeapAlloc, eax, HEAP_ZERO_MEMORY, ecx
		.if (eax)
			mov dword ptr [eax],0
			lea eax, [eax+4]
		.endif
		@strace	<"KernelHeapAlloc(", dwBytes, ")=", eax>
		ret
        align 4
KernelHeapAlloc endp

;--- alloc a kernel object

KernelHeapAllocObject proc public dwBytes:DWORD, lpName:ptr BYTE

		mov eax, lpName
		.if (!eax)
        	invoke KernelHeapAlloc, dwBytes
            jmp done
        .endif
       	invoke lstrlen, eax
        inc eax
        add eax, dwBytes
        invoke KernelHeapAlloc, eax
        .if (eax)
        	push eax
            add  eax, dwBytes
            invoke lstrcpy, eax, lpName
            pop  eax
        .endif
done:        
        ret
        align 4
KernelHeapAllocObject endp

KernelHeapFree proc public uses ebx handle:DWORD

		xor eax, eax
		.if (hKernelHeap)
			mov ebx, handle
			.if (ebx)
				.if (dword ptr [ebx-4])
					push ebx
					call dword ptr [ebx-4]
					.if (!eax)
						inc eax
						jmp done
					.endif
				.endif
                mov dword ptr [ebx],-1	;make sure this is no longer used
				lea ebx, [ebx-4]
				invoke HeapFree, hKernelHeap, 0, ebx
			.endif
		.endif
done:
		@strace	<"KernelHeapFree(", handle, ")=", eax>
		ret
        align 4
KernelHeapFree endp

;--- this function can be used to find a named object

KernelHeapFindObject proc public lpszName:ptr BYTE

local	phe:PROCESS_HEAP_ENTRY

		mov eax, hKernelHeap
		.if (eax)
			mov phe.lpData, 0
    	    .while (1)
				invoke HeapWalk, hKernelHeap, addr phe		
    	        .break .if (!eax)
        	    mov ecx, phe.lpData
                lea ecx, [ecx+4]
                xor edx, edx
	            .if ([ecx].SYNCOBJECT.dwType == SYNCTYPE_FILEMAPP)
                	mov edx, [ecx].FILEMAPOBJ.lpName
	            .elseif ([ecx].SYNCOBJECT.dwType == SYNCTYPE_SEMAPHOR)
                	mov edx, [ecx].SEMAPHORE.lpName
	            .elseif ([ecx].SYNCOBJECT.dwType == SYNCTYPE_MUTEX)
                	mov edx, [ecx].MUTEX.lpName
	            .elseif ([ecx].SYNCOBJECT.dwType == SYNCTYPE_TIMER)
                	mov edx, [ecx].TIMER.lpName
	            .endif
                .if (edx)
                	push ecx
    	        	invoke lstrcmp, lpszName, edx
                    pop ecx
        	        .if (!eax)
    	                mov eax, ecx
        	            .break
            	    .endif
                .endif
	        .endw
        .endif
		ret
        align 4
KernelHeapFindObject endp

KernelHeapWalk proc public pphe:ptr PROCESS_HEAP_ENTRY, dwType:DWORD

		mov eax, hKernelHeap
		.if (eax)
nextscan:        
			invoke HeapWalk, hKernelHeap, pphe		
            mov edx,dwType
            .if (eax && edx)
	            mov ecx, pphe
    	   	    mov ecx, [ecx].PROCESS_HEAP_ENTRY.lpData
                lea ecx, [ecx+4]
            	.if (edx != [ecx].SYNCOBJECT.dwType)
                	jmp nextscan
                .endif
                mov eax, ecx
	        .endif
        .endif
		ret
        align 4
KernelHeapWalk endp

;--- exit sequence. Delete kernel heap.

Deinstall	proc

		@strace	<"kernelheap deinstall enter">
		xor eax, eax
		xchg eax, hKernelHeap
		.if (eax)
			invoke  HeapDestroy, eax		;1 instance of DKRNL32.DLL
		.endif
		@strace	<"kernelheap deinstall exit">
		ret
        align 4
Deinstall	endp

        end

