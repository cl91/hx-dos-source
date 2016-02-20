
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
        include macros.inc

SE_ERR_NOASSOC	equ 31

        .CODE

ShellExecuteA proc public uses ebx hwnd:DWORD, lpVerb:ptr BYTE, lpFile:ptr BYTE,
				lpParameters:ptr BYTE, lpDirectory:ptr BYTE, nShowCmd:DWORD

local	dwEsp:dword
local	szPath[MAX_PATH]:byte

		xor eax, eax
        .if (lpVerb)
	   		invoke lstrcmpi, lpVerb, CStr("open")
        .endif
        .if (!eax)
        	invoke lstrlen, lpFile
            inc eax
            push eax
            xor eax, eax
            .if (lpParameters)
	            invoke lstrlen, lpParameters
            .endif
            pop ecx
            inc eax
            lea eax, [eax+ecx+3]
            and al,0FCh
            mov dwEsp, esp
            sub esp, eax
            mov ebx, esp
            invoke lstrcpy, ebx, lpFile
            .if (lpParameters)
	            invoke lstrcat, ebx, CStr(" ")
    	        invoke lstrcat, ebx, lpParameters
            .endif
            .if (lpDirectory)
            	invoke GetCurrentDirectoryA, MAX_PATH, addr szPath
                invoke SetCurrentDirectoryA, lpDirectory
            .endif
			invoke WinExec, ebx, nShowCmd
            .if (lpDirectory)
            	push eax
                invoke SetCurrentDirectoryA, addr szPath
                pop eax
            .endif
            mov esp, dwEsp
        .else
        	mov eax, SE_ERR_NOASSOC
        .endif
		@strace <"ShellExecuteA(", hwnd, ", ", lpVerb, ", ", lpFile, ", ", lpParameters, ", ", lpDirectory, ", ", nShowCmd, ")=", eax>                
		ret
        align 4
ShellExecuteA endp

		end
