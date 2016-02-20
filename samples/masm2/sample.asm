
;*** "hello world" for MASM/POASM with Win32 console functions
;*** type "nmake /f sample2m.mak" to create the binary

	.386
	.MODEL FLAT, stdcall
	option casemap:none

if 1
;--- to avoid usage of includes, declare the prototypes here

WriteConsoleA proto :dword, :dword, :dword, :dword, :dword
GetStdHandle  proto :dword
ExitProcess   proto :dword
STD_OUTPUT_HANDLE equ -11

else
;--- this branch uses the Win32Inc include files (MASM syntax)
;--- these may be downloaded from http://www.japheth.de/Download/win32inc.zip.
;--- there is also a simple method to create Win32 import libraries

WIN32_LEAN_AND_MEAN equ 1
	include windows.inc	

endif

	.CONST

szString    db 13,10,"hello, world.",13,10
ifdef ?POASM
LSTRING		equ sizeof szString	;POASM has problems with $ operator
else
LSTRING		equ $ - szString
endif

        .CODE

main    proc

local   dwWritten:dword
local   hConsole:dword

        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        mov     hConsole,eax

        invoke  WriteConsoleA, hConsole, addr szString, LSTRING, addr dwWritten, 0

        xor     eax,eax
        ret
main    endp

;--- entry

mainCRTStartup  proc stdcall
        invoke  main
        invoke  ExitProcess, eax
mainCRTStartup endp

        END mainCRTStartup

