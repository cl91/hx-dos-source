
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

CommandLineToArgvW proc public lpCmd:ptr WORD, pArgv:ptr DWORD

		xor eax, eax
		@strace <"CommandLineToArgvW(", lpCmd, ", ", pArgv, ")=", eax>                
		ret
        align 4
        
CommandLineToArgvW endp

		end
