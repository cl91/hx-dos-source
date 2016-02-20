
        .386
if ?FLAT
        .MODEL FLAT, stdcall
else
        .MODEL SMALL, stdcall
endif
		option casemap:none
        option proc:private

        include winbase.inc
        include wingdi.inc
        include dgdi32.inc
        include macros.inc

        .CODE

StartDocW proc public hdc:DWORD, lpDocInfo:ptr
StartDocW endp

StartDocA proc public hdc:DWORD, lpDocInfo:ptr

        xor eax, eax
		@strace <"StartDocA(", hdc, ", ", lpDocInfo, ")=", eax, " *** unsupp">
        ret
        align 4

StartDocA endp

EndDoc proc public hdc:DWORD

        xor eax, eax
		@strace <"EndDoc(", hdc, ")=", eax, " *** unsupp">
        ret
        align 4

EndDoc endp

StartPage proc public hdc:DWORD

        xor eax, eax
		@strace <"StartPage(", hdc, ")=", eax, " *** unsupp">
        ret
        align 4

StartPage endp

EndPage proc public hdc:DWORD

        xor eax, eax
		@strace <"EndPage(", hdc, ")=", eax, " *** unsupp">
        ret
        align 4

EndPage endp


		end
