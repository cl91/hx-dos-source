
;--- implements StgOpenStorage (and IStorage)

        .386
if ?FLAT
        .MODEL FLAT, stdcall
else
        .MODEL SMALL, stdcall
endif
		option casemap:none
        option proc:private

        include windef.inc
        include winbase.inc
        include winreg.inc
        include winuser.inc
        include objbase.inc
        include macros.inc

        .CODE

StgOpenStorage	proc public pwcsName:ptr WORD, pstgPriority:ptr, grfMode:dword,
		snbExclude:dword, res:dword, ppstgOpen:ptr 

		mov eax, E_FAIL
        @strace <"StgOpenStorage(", pwcsName, ", ", pstgPriority, ", ", grfMode, ", ", snbExclude, ", ", res, ", ", ppstgOpen, ")=", eax>
        ret
        align 4
StgOpenStorage endp

CreateStreamOnHGlobal proc public hGlobal:ptr, fDeleteOnRelease:dword, ppstm: ptr DWORD
		mov eax, E_FAIL
        @strace <"CreateStreamOnHGlobal(", hGlobal, ", ", fDeleteOnRelease, ", ", ppstm, ")=", eax>
        ret
        align 4
CreateStreamOnHGlobal endp

		end
