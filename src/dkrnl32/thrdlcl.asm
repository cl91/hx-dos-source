
;--- SetThreadLocale

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
	include macros.inc
	.cref
	.list

	.CODE

SetThreadLocale proc public lcid:DWORD

	mov ecx, lcid
	xor eax,eax
	.if ( ecx == 0 || ecx == LOCALE_SYSTEM_DEFAULT || ecx == LOCALE_USER_DEFAULT )
		inc eax
	.endif
	@strace <"SetThreadLocale(",lcid, ")=", eax, " *** part supp ***">
	ret

SetThreadLocale endp

	end
