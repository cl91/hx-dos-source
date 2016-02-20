
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

SHGetSpecialFolderLocation proc public hwndOwner:dword, nFolder:dword, ppidl:ptr DWORD

local	dwEsp:dword
local	szPath[MAX_PATH]:byte

		xor eax, eax
        mov ecx, ppidl
        mov [ecx], eax
        mov eax, E_FAIL
		@strace <"SHGetSpecialFolderLocation(", hwndOwner, ", ", nFolder, ", ", ppidl, ")=", eax>                
		ret
        align 4
SHGetSpecialFolderLocation endp

SHBrowseForFolderA proc public pPtr:ptr
		mov eax, E_FAIL
		@strace <"SHBrowseForFolderA(", pPtr, ")=", eax>                
        ret
        align 4
SHBrowseForFolderA endp

SHGetDesktopFolder proc public pPtr:ptr
		mov ecx, pPtr
        mov dword ptr [ecx],0
		mov eax, E_FAIL
		@strace <"SHGetDesktopFolder(", pPtr, ")=", eax>                
        ret
        align 4
SHGetDesktopFolder endp

		end
