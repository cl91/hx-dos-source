
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

SetThreadLocale proc public lcid:DWORD

        xor     eax,eax
		@strace	<"SetThreadLocale(",lcid, ")=", eax, " *** unsupp ***">
        ret
SetThreadLocale endp

        end

