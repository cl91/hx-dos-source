
;--- HXVDD is a NTVDM VDD

	.386
	.MODEL FLAT, stdcall
	option casemap:none

	.nolist
	.nocref
	include winbase.inc
	include winuser.inc
	include vddsvc.inc
	.list
	.cref
	include hxvdd.inc

;--- CStr() define a string in .CONST

CStr macro string:req
local sym,xxx
	.const
sym db string,0
	.code
	exitm <offset sym>
	endm

@DbgOutC macro xx
ifdef _DEBUG
	invoke OutputDebugString, CStr(<xx>)
endif
	endm

@DbgOut macro xx:REQ, parms:VARARG
ifdef _DEBUG
	pushad
	invoke wsprintfA, addr szText, CStr(<xx>), parms
	invoke OutputDebugString, addr szText
	popad
endif
	endm

	.data?

ifdef _DEBUG
szText	db 128 dup (?)
endif

	.code

;--- Init

Init    proc    stdcall

	@DbgOutC <"HXVDD.Init enter",13,10>
	@DbgOutC <"HXVDD.Init exit",13,10>
	ret
	align 4

Init    endp

;--- Dispatch
;--- function in edx

Dispatch    proc    stdcall uses ebx edi

	@DbgOutC <"HXVDD.Dispatch enter",13,10>
	invoke setCF, 0
	invoke getEDX
	.if ( eax == VDD_OPENCLIPBOARD )
		invoke OpenClipboard, NULL
		@DbgOut <"Dispatch.OpenClipboard()=%X",13,10>, eax
	.elseif ( eax == VDD_CLOSECLIPBOARD )
		invoke CloseClipboard
		@DbgOut <"Dispatch.CloseClipboard()=%X",13,10>, eax
	.elseif ( eax == VDD_EMPTYCLIPBOARD )
		invoke EmptyClipboard
		@DbgOut <"Dispatch.EmptyClipboard()=%X",13,10>, eax
	.elseif ( eax == VDD_GETCLIPBOARDDATA )
		invoke getECX
		mov edi, eax
		invoke GetClipboardData, eax
		@DbgOut <"Dispatch.GetClipboardData(%u)=%X",13,10>, edi, eax
	.elseif ( eax == VDD_SETCLIPBOARDDATA )
		invoke getECX	;get uFormat parameter
		mov edi, eax
		invoke getEBX	;get handle parameter
		mov ebx, eax
		invoke SetClipboardData, edi, ebx
		@DbgOut <"Dispatch.SetClipboardData(%u, %X)=%X",13,10>, edi, ebx, eax
	.elseif ( eax == VDD_ISCLIPBOARDFORMATAVAILABLE )
		invoke getECX	;get uFormat parameter
		mov edi, eax
		invoke IsClipboardFormatAvailable, eax
		@DbgOut <"Dispatch.IsClipboardFormatAvailable(%u)=%X",13,10>, edi, eax
	.elseif ( eax == VDD_ENUMCLIPBOARDFORMATS )
		invoke getECX	;get uFormat parameter
		mov edi, eax
		invoke EnumClipboardFormats, eax
		@DbgOut <"Dispatch.EnumClipboardFormats(%u)=%X",13,10>, edi, eax
	.elseif ( eax == VDD_GLOBALALLOC )
		invoke getECX	;get flags
		mov edi, eax
		invoke getEBX	;get size
		mov ebx, eax
		invoke GlobalAlloc, edi, eax
		@DbgOut <"Dispatch.GlobalAlloc(%X, %X)=%X",13,10>, edi, ebx, eax
	.elseif ( eax == VDD_GLOBALLOCK )
		invoke getECX	;get handle
		mov edi, eax
		invoke GlobalLock, eax
		@DbgOut <"Dispatch.GlobalLock(%X)=%X",13,10>, edi, eax
	.elseif ( eax == VDD_GLOBALUNLOCK )
		invoke getECX	;get handle
		mov edi, eax
		invoke GlobalUnlock, eax
		@DbgOut <"Dispatch.GlobalUnlock(%X)=%X",13,10>, edi, eax
	.else
		@DbgOut <"HXVDD: unknown function EDX=%X",13,10>, eax
		invoke setCF, 1
		xor eax, eax
	.endif
	invoke setEAX, eax
	@DbgOutC <"HXVDD.Dispatch exit",13,10>
	ret
	align 4

Dispatch    endp

;*** main proc ***

DllMain proc stdcall hInstance:dword, reason:dword, lpReserved:dword

	mov eax, reason
	.if (eax == DLL_PROCESS_ATTACH)
		@DbgOutC <"HXVDD process attach",13,10>
		mov eax,1
	.elseif (eax == DLL_PROCESS_DETACH)
		@DbgOutC <"HXVDD process detach",13,10>
	.elseif (eax == DLL_THREAD_ATTACH)
		@DbgOutC <"HXVDD thread attach",13,10>
	.elseif (eax == DLL_THREAD_DETACH)
		@DbgOutC <"HXVDD thread detach",13,10>
	.endif
	ret

DllMain endp

	END DllMain

