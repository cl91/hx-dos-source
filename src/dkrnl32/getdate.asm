
		.386
if ?FLAT
		.MODEL FLAT, stdcall
else
		.MODEL SMALL, stdcall
endif
		option casemap:none
        option proc:private

		include winbase.inc
        include dkrnl32.inc
		include macros.inc

		.code

PutNumber	proc uses ebx esi

   		mov		ecx, 10
		mov		ebx, eax
		xor		esi, esi
L4B1:
        or      eBX,eBX
        je      exit
		mov		eax, ebx
        div     eCX
		mov		ebx, eax
		mov		al, dl
		add		al, '0'
		push	eax
		inc		esi
        jmp     L4B1
exit:
		.while (esi)
			pop eax
			stosb
		.endw
		mov al, '0'
		stosb
		ret		
        align 4
PutNumber	endp

GetDateFormatA	proc public uses ebx esi edi lcid:DWORD, dwFlags:DWORD, pDate:ptr SYSTEMTIME, lpFormat:ptr BYTE, lpDateStr:ptr BYTE, cchDate:DWORD

local	szDate[64]:byte
local	systemtime:SYSTEMTIME

		mov ebx, pDate
		.if (!ebx)
			lea ebx, systemtime
			invoke GetSystemTime, ebx
		.endif
		lea edi, szDate
if 0
		mov esi, lpFormat
		.if (!esi)
			mov esi, CStr("ddd',' MMM dd yyyy")
		.endif
endif
		movzx eax, [ebx].SYSTEMTIME.wMonth
		invoke	PutNumber
		mov al, '/'
		stosb
		movzx eax, [ebx].SYSTEMTIME.wDay
		invoke	PutNumber
		mov al, '/'
		stosb
		movzx eax, [ebx].SYSTEMTIME.wYear
		invoke	PutNumber
		mov al, 0
		stosb
		invoke lstrlen, addr szDate
		inc eax
		push eax
		mov ecx, cchDate
		.if (ecx)
			.if (ecx > eax)
				mov ecx, eax
			.endif
            invoke CopyMemory, lpDateStr, addr szDate, ecx
		.endif
		pop eax
		@strace	<"GetDateFormatA(", lcid, ", ", dwFlags, ", ", pDate, ", ", lpFormat, ", ", lpDateStr, ", ", cchDate, ")=", eax>
		ret
        align 4
GetDateFormatA	endp


GetTimeFormatA  proc public uses ebx esi edi lcid:DWORD, dwFlags:DWORD, pTime:ptr SYSTEMTIME,lpFormat:ptr BYTE, lpTimeStr:ptr BYTE, cchTime:DWORD

local	systemtime:SYSTEMTIME
local   szTime[64]:byte

        mov ebx, pTime
		.if (!ebx)
			lea ebx, systemtime
			invoke GetSystemTime, ebx
		.endif
        lea edi, szTime
        movzx eax, [ebx].SYSTEMTIME.wHour
		invoke	PutNumber
        mov al, ':'
		stosb
        movzx eax, [ebx].SYSTEMTIME.wMinute
		invoke	PutNumber
        mov al, ':'
		stosb
        movzx eax, [ebx].SYSTEMTIME.wSecond
		invoke	PutNumber
		mov al, 0
		stosb
        invoke lstrlen, addr szTime
		inc eax
		push eax
        mov ecx, cchTime
		.if (ecx)
			.if (ecx > eax)
				mov ecx, eax
			.endif
            invoke CopyMemory, lpTimeStr, addr szTime, ecx
		.endif
		pop eax
		@strace	<"GetTimeFormatA(", lcid, ", ", dwFlags, ", ", pTime, ", ", lpFormat, ", ", lpTimeStr, ", ", cchTime, ")=", eax>
        ret
        align 4

GetTimeFormatA  endp

GetDateFormatW	proc public lcid:DWORD, dwFlags:DWORD, pDate:ptr SYSTEMTIME, lpFormat:ptr WORD, lpDateStr:ptr WORD, cchDate:DWORD

local	lpAStr:dword

		mov eax, lpFormat
        .if (eax)
			call	ConvertWStr
        .endif
        mov		ecx, cchDate
		sub		esp, ecx
        sub		esp, ecx
        mov		lpAStr, esp
        invoke GetDateFormatA, lcid, dwFlags, pDate, eax, lpAStr, cchDate
        .if (eax)
        	invoke ConvertAStrN, lpAStr, lpDateStr, cchDate
        .endif
		@strace	<"GetDateFormatW(", lcid, ", ", dwFlags, ", ", pDate, ", ", lpFormat, ", ", lpDateStr, ", ", cchDate, ")=", eax>
        ret
        align 4
GetDateFormatW	endp

GetTimeFormatW  proc public lcid:DWORD, dwFlags:DWORD, pTime:ptr SYSTEMTIME, lpFormat:ptr BYTE, lpTimeStr:ptr BYTE, cchTime:DWORD

local	lpAStr:dword

		mov eax, lpFormat
        .if (eax)
			call	ConvertWStr
        .endif
        mov		ecx, cchTime
		sub		esp, ecx
        sub		esp, ecx
        mov		lpAStr, esp
        invoke GetTimeFormatA, lcid, dwFlags, pTime, eax, lpAStr, cchTime
        .if (eax)
        	invoke ConvertAStrN, lpAStr, lpTimeStr, cchTime
        .endif
		@strace	<"GetTimeFormatW(", lcid, ", ", dwFlags, ", ", pTime, ", ", lpFormat, ", ", lpTimeStr, ", ", cchTime, ")=", eax>
        ret
        align 4
GetTimeFormatW  endp

		end
