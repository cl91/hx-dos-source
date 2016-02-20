
        .386
if ?FLAT
        .MODEL FLAT, stdcall
else
        .MODEL SMALL, stdcall
endif
        option proc:private
        option casemap:none

        include winbase.inc
        include excpt.inc
        include macros.inc

;STATUS_UNWIND	equ 0C0000027h
STATUS_UNWIND	equ 0C0000026h

?CREATECONTEXT	equ 0

        .DATA

        .CODE

		assume fs:nothing

if ?CREATECONTEXT
SaveContext proto stdcall :ptr CONTEXT
endif

;*** this function is pretty "undocumented"
;*** but described sufficiently by Matt Pietrek in MSJ 1997/01
;*** should unwind stack if exception occured and a "higher"
;*** handler has choosen to handle it

RtlUnwind proc public uses esi edi ebx pRegistrationFrame:ptr EXCEPTION_REGISTRATION,
		returnAddr:DWORD, pExceptRecord:ptr EXCEPTION_RECORD, _eax_value:dword

if ?CREATECONTEXT
local	context:CONTEXT
endif

local	_er:EXCEPTION_RECORD

        @trace  <"RtlUnwind(">
        @tracedw pRegistrationFrame
        @trace	<", ">
        @tracedw returnAddr
        @trace	<", ">
        @tracedw pExceptRecord
        @trace	<", ">
        @tracedw _eax_value
		@trace	<")",13,10>

		mov 	ecx, pExceptRecord
        .if (!ecx)
        	lea ecx, _er
            mov [ecx].EXCEPTION_RECORD.ExceptionCode, STATUS_UNWIND
            mov eax, [ebp+4]
            mov [ecx].EXCEPTION_RECORD.ExceptionAddress, eax
            mov [ecx].EXCEPTION_RECORD.ExceptionRecord, 0
            mov [ecx].EXCEPTION_RECORD.NumberParameters, 0
            mov [ecx].EXCEPTION_RECORD.ExceptionInformation, 0
            mov pExceptRecord, ecx
        .endif
        .if (pRegistrationFrame)
            mov [ecx].EXCEPTION_RECORD.ExceptionFlags, _EH_UNWINDING
        .else
            mov [ecx].EXCEPTION_RECORD.ExceptionFlags, _EH_UNWINDING or _EH_EXIT_UNWIND
        .endif

if ?CREATECONTEXT        
        invoke SaveContext, addr context
        mov eax, _eax_value
        mov context.rEax, eax
endif

        mov		edi, fs:[THREAD_INFORMATION_BLOCK.pvExcept]
        .while ((edi != -1) && (edi != pRegistrationFrame))
if ?CREATECONTEXT            
			lea		eax,context
else
			xor		eax, eax
endif
if 1
	        mov		esi, esp
			invoke	[edi].EXCEPTION_REGISTRATION.ExceptionHandler, \
            	pExceptRecord, edi, eax, 0
	        mov		esp, esi
        	mov		edi, [edi].EXCEPTION_REGISTRATION.prev_structure
            mov		fs:[THREAD_INFORMATION_BLOCK.pvExcept],edi
else

	        invoke	FatalAppExit,0, CStr(<13,10,"DKRNL32: stopped in RtlUnwind(), app terminated",13,10>)
endif        
        .endw
        ret
        
RtlUnwind endp

end

