
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

        .DATA

        .CODE

GetFileType proc public uses ebx handle:dword

        mov     ebx,handle
        mov     ax,4400h
        int     21h
        jc      unknown
;        test    dh,80h				;device?
        test    dl,80h				;device?
        jnz     device
        mov     eax,FILE_TYPE_DISK
        jmp     exit
device:
        mov     eax,FILE_TYPE_CHAR
        jmp     exit
unknown:
        mov     eax,FILE_TYPE_UNKNOWN
exit:
        @strace  <"GetFileType(", handle, ")=", eax>
        ret
GetFileType endp

end

