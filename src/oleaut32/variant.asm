
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
        include oleauto.inc
        include macros.inc
        .list
        .cref

VT_EMPTY 	equ 0
VT_I2		equ 2
VT_BSTR		equ 7
VT_I1		equ 16
VT_UI1		equ 17
VT_UI2		equ 18

BSTR typedef ptr WORD

VARIANT struct
vt		word ?
res1	word ?
res2	word ?
res3	word ?
union
lVal	DWORD ?
bstrVal	BSTR ?
qVal	QWORD ?
ends
VARIANT ends
        
        .CODE

VariantInit proc public pvt:ptr VARIANT

		mov ecx, pvt
        xor eax, eax		;eax=S_OK
        mov [ecx],eax
        mov [ecx+4],eax
        mov [ecx+8],eax
        mov [ecx+12],eax
        mov [ecx].VARIANT.vt, VT_EMPTY
        ret

VariantInit endp

VariantClear proc public pvt:ptr VARIANT

		mov ecx,pvt
        .if ([ecx].VARIANT.vt == VT_BSTR)
        	invoke SysFreeString, [ecx].VARIANT.bstrVal
        .endif
		mov ecx,pvt
        mov [ecx].VARIANT.vt, VT_EMPTY
		mov eax,S_OK
		ret
        
VariantClear endp

VariantCopyInd proc public pvtDest:ptr VARIANT, pvtSrc:ptr VARIANT
VariantCopyInd endp

VariantCopy proc public uses esi edi pvtDest:ptr VARIANT, pvtSrc:ptr VARIANT

		@trace <"VariantCopy",13,10>
		mov edi, pvtDest
        mov esi, pvtSrc
        movsd
        movsd
        movsd
        movsd
        mov edi,pvtDest
        .if ([edi].VARIANT.vt == VT_BSTR)
        	invoke SysStringByteLen, [edi].VARIANT.bstrVal
        	invoke SysAllocStringByteLen, [edi].VARIANT.bstrVal, eax
            mov [edi].VARIANT.bstrVal, eax
        .endif
		mov eax,S_OK
		ret
        
VariantCopy endp

VariantChangeType proc public uses ebx esi edi pvtDest:ptr VARIANT, pvtSrc:ptr VARIANT, wFlags:DWORD, wType:DWORD

local	dwESP:DWORD
local	szTemp[64]:byte

		@trace <"VariantChangeType",13,10>
       	invoke VariantInit, pvtDest
		mov ebx, wType
        .if (bx == VT_BSTR)
        	mov ecx, pvtSrc
            mov dx, [ecx].VARIANT.vt
            .if (dx == VT_BSTR)
            	invoke VariantCopy, pvtDest, pvtSrc
            .else
				mov eax, [ecx].VARIANT.lVal
                .if (dx == VT_I2 || dx == VT_UI2)
                	movzx eax, ax
                .elseif (dx == VT_I1 || dx == VT_UI1)
                	movzx eax, al
                .endif
            	invoke wsprintf, addr szTemp,CStr("%u"), eax
                inc eax
                mov ecx, eax
                add eax, eax
                sub esp, eax
				lea esi, szTemp
                @loadesp edi
                mov ah,0
@@:                
                lodsb
                stosw
                loop @B
                invoke SysAllocString, esp
                mov ecx, pvtDest
                mov [ecx].VARIANT.bstrVal,eax
                mov [ecx].VARIANT.vt, VT_BSTR
                mov esp, dwESP
            .endif
        .else
			invoke VariantCopy, pvtDest, pvtSrc
        .endif
		ret
        
VariantChangeType endp

VariantChangeTypeEx proc public uses ebx esi edi pvtDest:ptr VARIANT, pvtSrc:ptr VARIANT, lcid:DWORD, wFlags:DWORD, wType:DWORD
		invoke VariantChangeType, pvtDest, pvtSrc, wFlags, wType
		ret
VariantChangeTypeEx endp

		end
