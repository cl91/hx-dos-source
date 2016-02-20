
;--- implements WIDE functions

        .386
if ?FLAT
        .MODEL FLAT, stdcall
else
        .MODEL SMALL, stdcall
endif
		option proc:private
        option casemap:none

        include winbase.inc
        include winerror.inc
		include dkrnl32.inc
        include macros.inc

        .CODE

GetLocaleInfoW proc public lcid:dword,
          lctype:dword, pString:dword, cString:dword

        invoke  SetLastError,ERROR_INVALID_PARAMETER
        xor     eax,eax
		@strace	<"GetLocaleInfoW(", lcid, ", ", lctype, ", ", pString, ", ", cString, ")=", eax, " *** unsupp ***">
        ret
        align 4
GetLocaleInfoW endp

EnumSystemLocalesW proc public pBuffer:dword, flags:dword
        xor     eax,eax
		@strace	<"EnumSystemLocalesW(", pBuffer, ", ", flags, ")=", eax, " *** unsupp ***">
        ret
        align 4
EnumSystemLocalesW endp

end

