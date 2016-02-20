
	.386
if ?FLAT
	.MODEL FLAT, stdcall
else
	.MODEL SMALL, stdcall
endif
	option casemap:none
	option proc:private

	include winbase.inc
	include dpmi.inc
	include winerror.inc
	include macros.inc

	.CODE

GetNumberFormatA proc public lcid:dword, dwFlags:dword, lpValue:ptr BYTE, lpFormat:ptr, lpNumberStr:ptr BYTE, cchNumber:dword

	.if (cchNumber)
		invoke lstrcpyn, lpNumberStr, lpValue, cchNumber
		invoke lstrlen, lpNumberStr
		inc eax
	.else
		invoke lstrlen, lpValue
		inc eax
	.endif
	@strace <"GetNumberFormatA(", lcid, ", ", dwFlags, ", ", lpValue, ", ", lpFormat, ", ", lpNumberStr, ", ", cchNumber, ")=", eax>
	ret
	align 4

GetNumberFormatA endp

	end
