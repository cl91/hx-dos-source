
        .386
if ?FLAT
        .MODEL FLAT, stdcall
else
        .MODEL SMALL, stdcall
endif
		option casemap:none

        include winbase.inc
        include dkrnl32.inc

        .DATA

g_dwErrorMode dd 0

        END

