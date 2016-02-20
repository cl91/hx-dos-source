
        .386
if ?FLAT
        .MODEL FLAT, stdcall
else
        .MODEL SMALL, stdcall
endif
		option casemap:none
        option proc:private

        include winbase.inc
        include macros.inc

        .CODE

CommDlgExtendedError proc public
		xor eax, eax
		@strace <"CommDlgExtendedError()=", eax>
		ret
CommDlgExtendedError endp

GetOpenFileNameA proc public lpOFN:ptr
		xor eax, eax
		@strace <"GetOpenFileNameA(", lpOFN, ")=", eax>
		ret
GetOpenFileNameA endp

GetSaveFileNameA proc public lpSFN:ptr
		xor eax, eax
		@strace <"GetSaveFileNameA(", lpSFN, ")=", eax>
		ret
GetSaveFileNameA endp

PrintDlgA proc public lpPD:ptr
		xor eax, eax
		@strace <"PringDlgA(", lpPD, ")=", eax>
		ret
PrintDlgA endp

		end
