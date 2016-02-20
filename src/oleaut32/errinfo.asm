
        .386
if ?FLAT
        .MODEL FLAT, stdcall
else
        .MODEL SMALL, stdcall
endif
		option casemap:none
        option proc:private

		.nolist
        .nocref
        include winbase.inc
        include winuser.inc
        include objbase.inc
        include oleauto.inc
        include macros.inc
        .list
        .cref

		.DATA
        
g_pErrorInfo dd 0

        .CODE

SetErrorInfo proc public dwRes:DWORD, pErrorInfo:ptr

        mov eax, S_OK
        .if (pErrorInfo)
        	invoke vf(pErrorInfo, IUnknown, AddRef)
        .endif
        .if (g_pErrorInfo)
        	invoke vf(g_pErrorInfo, IUnknown, Release)
        .endif
        mov eax, pErrorInfo
        mov g_pErrorInfo, eax
		@strace	<"SetErrorInfo(", dwRes, ", ", pErrorInfo, ")=", eax>
        ret

SetErrorInfo endp

		end
