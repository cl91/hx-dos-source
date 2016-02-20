
        .586
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

		.code

QueryDosDeviceA	proc public lpDeviceName:ptr BYTE, lpTargetPath:ptr BYTE, ucchMax:DWORD

		xor eax, eax
        mov ecx, lpTargetPath
        mov [ecx],ax
		@strace <"QueryDosDeviceA(", lpDeviceName, ", ", lpTargetPath, ", ", ucchMax, ")=", eax, " *** unsupp ***">
		ret

QueryDosDeviceA	endp

		end
