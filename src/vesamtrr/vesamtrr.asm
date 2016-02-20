
;*** use IDT to jump in ring 0 and get/set msr registers
;*** requires read/write access to IDT, read access to GDT

	.586
if ?FLAT
	.MODEL FLAT,stdcall
@flat	equ <ds>
else
	.MODEL SMALL,stdcall
@flat	equ <gs>
endif
	option casemap:none

if ?FLAT eq 0
	public __STACKSIZE
	public __HEAPSIZE
	public __pMoveHigh
__STACKSIZE equ 8000h
__HEAPSIZE equ 8000h
endif

	.nolist
	.nocref
	include function.inc
	include vesa32.inc
	include macros.inc
	include dpmi.inc
	.list
	.cref

wvsprintfA proto stdcall :dword, :dword, :dword

REGS	struct
_eax	dd ?
_edx	dd ?
_ecx	dd ?
_ebx	dd ?
REGS	ends

BINT	equ 5	;use this idt entry

	.data

hConOut	dd 0
dwLDT	dd 0
dqLDT0	dq 0
dwLFBSize dd 0
dwPhysBase dd 0
bUsage	db 0
bStatus	db 0
bVesa	db 1
__pMoveHigh dd 0

regions	label word
	dw 3*4 dup (0)
endregions label byte

	.CODE

readmsr proc
	rdmsr
	iretd
	align 4
readmsr endp

writemsr proc
	wrmsr
	iretd
	align 4
writemsr endp

WriteConsole proc uses esi pszText:ptr byte

	mov esi, pszText
	.while (1)
		lodsb
		.break .if (!al)
		mov dl,al
		mov ah,2
		int 21h
	.endw
	ret
	align 4

WriteConsole endp

printf proc c pszText:ptr byte, parms:VARARG

local	dwWritten:DWORD
local	szText[128]:byte

	invoke wvsprintfA,addr szText,pszText, addr parms
	invoke WriteConsole, addr szText
	ret
	align 4
printf endp

GetVesaInfo_ proc public uses edi esi ebx pVesaInfo:ptr VESAINFO

local	dosmemsel:dword
local	linDosMem:dword
local	rcptr:dword
local	rmcs:RMCS

	xor eax,eax
	mov dosmemsel,eax
	mov ax,0100h		;alloc DOS memory
	mov bx,20h			;256+256 bytes = sizeof VESAINFO
	int 31h
	jc svmx_er
	mov dosmemsel,edx
	mov rmcs.rES,ax
	mov rmcs.rAX,4F00h
	mov rmcs.rDI,0
	mov rmcs.rSSSP,0
						;clear the VESA info buffer
	movzx eax,ax
	shl eax,4
	mov linDosMem, eax

	mov edi,eax
	mov ecx,200h/4
	xor eax,eax
ife ?FLAT
	push es
	push @flat
	pop es
endif
	rep stosd
ife ?FLAT
	pop es
endif

	mov ebx, linDosMem
;	mov eax,"ASEV"
	mov eax,"2EBV"
	mov @flat:[ebx],eax
	push ebx
	lea edi,rmcs
ife ?FLAT
	push es
	push ss
	pop es
endif
	mov bx,0010h
	mov cx,0000h
	mov ax,0300h
	int 31h
ife ?FLAT
	pop es
endif
	pop ebx
	jc svmx_er
	cmp rmcs.rAX,004Fh
	jnz svmx_er
	mov esi,linDosMem 
	mov edi, pVesaInfo
	mov ecx,sizeof VESAINFO
ife ?FLAT
	push ds
	push @flat
	pop ds
endif
	rep movsb
ife ?FLAT
	pop ds
endif
	mov eax,1
	jmp svmx_ex
svmx_er:
	xor eax,eax
svmx_ex:
	mov edx,dosmemsel
	and edx,edx
	jz @F
	push eax
	mov ax,0101h
	int 31h
	pop eax
@@:
	ret
	align 4
GetVesaInfo_ endp

;--- copied from VESA32.ASM, but without phys2lin translation of LFB

GetVesaLFBAddr proc public uses ebx esi edi dwMode:dword

local	linmem:dword
local	dosmemsel:dword
local	rmcs:RMCS

	xor eax,eax
	mov dosmemsel,eax
	mov ax,0100h				  ;alloc DOS memory
	mov bx,10h					  ;256 bytes (sizeof SVGAINFO)
	int 31h
	jc getvesainfo_er
	mov dosmemsel,edx
	mov rmcs.rSSSP,0
	mov rmcs.rDI,0
	mov rmcs.rES,ax
	mov rmcs.rAX,4F01h
	mov ecx,dwMode
	and ch,03Fh 				  ;
	mov rmcs.rCX,cx
	movzx eax,ax
	shl eax,4
	mov linmem,eax
	mov edi,eax
	mov ecx,sizeof SVGAINFO/4
	xor eax,eax
ife ?FLAT
	push es
	push @flat
	pop es
endif
	rep stosd
ife ?FLAT
	pop es
endif
	lea edi,rmcs
	push es
	push ss
	pop es
	mov bx,0010h
	mov cx,0000h
	mov ax,0300h
	int 31h
	pop es
	jc getvesainfo_er
	cmp rmcs.rAX,004Fh
	jnz getvesainfo_er
	mov edi,linmem
	test @flat:[edi].SVGAINFO.ModeAttributes, VESAATTR_LFB_SUPPORTED
	jz noLFB
	mov eax,@flat:[edi].SVGAINFO.PhysBasePtr
	and eax, eax
	jz noLFB
	jmp getvesainfo_ex
noLFB:
getvesainfo_er:
	xor eax,eax
getvesainfo_ex:
	mov edx,dosmemsel
	and edx,edx
	jz @F
	push eax
	mov ax,0101h
	int 31h
	pop eax
@@:
	ret
	align 4
GetVesaLFBAddr endp

;--- call a ring 0 proc

r0proc proc uses esi edi ebx lpfnProc:dword, dwCodeSel:dword, regs:ptr REGS

local	idt:fword

	sidt idt
	mov edi,dword ptr idt+2
	add edi,BINT*8
	mov ecx, lpfnProc

	cli
	push @flat:[edi+0]
	push @flat:[edi+4]

	mov @flat:[edi+0],cx
	shr ecx,16
	mov @flat:[edi+6],cx
if 0
	and byte ptr @flat:[edi+4],09Fh	;reset priviledge level to r0 in int gate
else
	mov word ptr @flat:[edi+4],0EE00h	;386 interrupt gate
endif
	mov eax, dwCodeSel
	mov @flat:[edi+2],ax
	mov esi, regs

	mov eax, [esi].REGS._eax
	mov ecx, [esi].REGS._ecx
	mov edx, [esi].REGS._edx
	mov ebx, [esi].REGS._ebx

	int BINT

	mov [esi].REGS._eax, eax
	mov [esi].REGS._ecx, ecx
	mov [esi].REGS._edx, edx 
	mov [esi].REGS._ebx, ebx 

	pop @flat:[edi+4]
	pop @flat:[edi+0]

	sti
	ret
	align 4
r0proc endp

GetCmdLine proc uses ebx esi edi

	mov ah,51h
	int 21h
	push ds
	mov ds,ebx 
	mov esi, 0080h
	lodsb
	mov cl, al
	mov edi, offset regions
	.while (cl)
		lodsb
		dec cl
		.if ((al == '/') || (al == '-'))
			.if (cl)
				lodsb
				dec cl
				or al,20h
				.if ((al == '?') || (al == 'h'))
					or es:[bUsage], 1
				.elseif (al == 'i')
					or es:[bStatus], 1
					mov es:[bVesa],0
				.elseif (((al == 'b') || (al == 'c') || (al == 'p') || (al == 't') || (al == 'u')) && (byte ptr [esi] == '='))
					mov bl,al
					inc esi
					dec cl
					call gethex
					.if ((!CARRY?) && (eax < 10000h))
						.if (byte ptr [esi] == '-')
							push eax
							inc esi
							dec cl
							call gethex
							pop edx
							.if ((!CARRY?) && (eax < 10000h) && (eax > edx))
								.if (edi < offset endregions)
									mov es:[edi+0],dx
									mov es:[edi+2],ax
									.if (bl == 'b')
										mov word ptr es:[edi+4],"WB"
									.elseif (bl == 'c')
										mov word ptr es:[edi+4],"WC"
									.elseif (bl == 'p')
										mov word ptr es:[edi+4],"WP"
									.elseif (bl == 't')
										mov word ptr es:[edi+4],"WT"
									.elseif (bl == 'u')
										mov word ptr es:[edi+4],"UC"
									.endif
									add edi, 3*2
								.endif
							.endif
						.endif
					.endif
				.endif
			.endif
		.endif
	.endw
	pop ds
	.if (bUsage)
		jmp usage
	.endif
	mov eax,1
	ret
usage:
;	invoke printf, CStr("usage: VESAMTRR <WC|UC>",13,10)
	invoke printf, CStr("VESAMTRR v1.3 (C) Japheth 2005-2007",13,10)
	invoke printf, CStr("usage: VESAMTRR [options]",13,10)
	invoke printf, CStr(" options: -? display this help",13,10)
	invoke printf, CStr("          -i display MTRR status",13,10)
	invoke printf, CStr("          -b=ssss-eeee set type of memory range to WB",13,10)
	invoke printf, CStr("          -c=ssss-eeee set type of memory range to WC",13,10)
	invoke printf, CStr("          -p=ssss-eeee set type of memory range to WP",13,10)
	invoke printf, CStr("          -t=ssss-eeee set type of memory range to WT",13,10)
	invoke printf, CStr("          -u=ssss-eeee set type of memory range to UC",13,10)
	invoke printf, CStr("          (",3Ch,"ssss",3Eh," and ",3Ch,"eeee",3Eh," are segment addresses ",3Eh,"= A000 and ",3Ch,"= FFFF)",13,10)
	invoke printf, CStr("Without option VESAMTRR will setup an MTRR for VESA LFB with type WC.",13,10)
	invoke printf, CStr("On DOS this may increase VESA memory write access speed.",13,10)
	invoke printf, CStr("Thanks to RayeR for this hint.",13,10)
	xor eax, eax
	ret
gethex:
	mov ch,0
	xor edx, edx
	.while (cl)
		mov al,[esi]
		cmp al,'0'
		jb donehex
		cmp al,'9'
		jbe @F
		or al,20h
		cmp al,'a'
		jb donehex
		cmp al,'g'
		jnc donehex
		sub al,27h
@@:
		sub al,'0'
		movzx eax,al
		shl edx, 4
		add edx, eax
		inc esi
		inc ch
		dec cl
	.endw
donehex:
	mov eax, edx
	cmp ch,1
	retn
	align 4
GetCmdLine endp

;--- get a ring 0 code selector
;--- search in GDT, then LDT

GetR0CS proc uses ebx

local	dwBase:dword
local	dfOldExc0E:fword
local	gdt:fword

	mov ebx,cs
	mov ax,0006
	int 31h
	mov word ptr dwBase+0,dx
	mov word ptr dwBase+2,cx

;--- first search in GDT

	mov ax,0202h
	mov bl,0Eh
	int 31h
	mov dword ptr dfOldExc0E+0,edx
	mov word ptr dfOldExc0E+4,cx
	mov ecx,cs
	mov edx,myexc0E
	mov ax,0203h
	int 31h

	sgdt gdt
	mov edx,dword ptr gdt+2
	movzx ecx,word ptr gdt
	inc ecx
	shr ecx, 3
	mov ebx, 0
	.while (ecx)
		mov ah,@flat:[edx+ebx*8+7]
		mov al,@flat:[edx+ebx*8+4]
		shl eax,16
		mov ax,@flat:[edx+ebx*8+2]
		.if (eax == dwBase)
			mov ax,@flat:[edx+ebx*8+5]
			and ah,0EFh
			.break .if (ax == 0CF9Bh)
		.endif
		inc ebx
		dec ecx
	.endw
	.if (!ecx)
		xor ebx, ebx
		sldt bx
		xor eax, eax
		and ebx, ebx
		jz exit				;no LDT defined, giving up
		and bl,0F8h
		mov ah,@flat:[edx+ebx+7]
		mov al,@flat:[edx+ebx+4]
		shl eax,16
		mov ax,@flat:[edx+ebx+2]	;get base of LDT
		mov edx, @flat:[eax+0]
		mov ecx, @flat:[eax+4]
		mov dword ptr dqLDT0+0, edx
		mov dword ptr dqLDT0+4, ecx
		mov word ptr @flat:[eax+0],-1	;limit [00-15]
		mov ecx, dwBase
		mov word ptr @flat:[eax+2],cx	;base [00-15]
		shr ecx, 16
		mov byte ptr @flat:[eax+4],cl	;base [16-23]
		mov word ptr @flat:[eax+5],0CF9Bh	;attr + limit [16-19]
		mov byte ptr @flat:[eax+7],ch	;base [24-31]
		mov dwLDT, eax
		mov eax, 4						;use first entry in LDT
		jmp exit
	.endif
	shl ebx,3
	mov eax, ebx
exit:
	push eax
	mov edx,dword ptr dfOldExc0E+0
	mov cx,word ptr dfOldExc0E+4
	mov bl,0Eh
	mov ax,0203h
	int 31h
	pop eax
	ret
myexc0E:
	xor eax, eax
	mov dword ptr [esp+3*4],offset exit
	retf
	align 4

GetR0CS endp

SetFixedMtrr proc uses esi edi ebx r0cs:dword

local	dwCB:dword
local	dwOfs:dword
local	regs:REGS

	mov esi, offset regions
	.while ((esi < offset endregions) && (word ptr [esi+4]))
		call getcb
		mov dwCB, edx
		movzx eax,word ptr [esi+0]
		movzx edi,word ptr [esi+2]
		shr eax, 8			;C000 -> C0
		shr edi, 8
		.if (eax < 080h)
			invoke printf, CStr("fixed MTRRs below 8000h cannot be set yet",13,10)
		.elseif (eax < 0C0h)
			sub eax, 080h   ;80,84 .. B8,BC -> 00,04 .. 38,3C
			sub edi, 080h
			shr eax, 2		;00,04 .. 38,3C -> 00,01 .. 0E,0F
			shr edi, 2
			sub edi, eax
			inc edi			;16k pages to modify
			mov ecx, eax
			and ecx, 7
			shr eax, 3		;00-07 -> 258, 08-0F -> 259
			mov ebx, 258h
			add ebx, eax
			mov [regs]._ecx, ebx

			mov eax,0FFh
			shl ecx, 3		;0,1,2,3 -> 0,8,16,24
			.if (ecx > 31)
				xor eax, eax
				sub ecx,32
				mov edx,0ffh
				shl edx, cl
			.else
				shl eax, cl
				mov edx, 0ffh
			.endif
			mov ecx, edx

			.while (edi)
				push ecx
				push eax
				invoke r0proc, offset readmsr, r0cs, addr regs
				pop eax
				.while (edi && eax)
					mov edx,dwCB
					and edx, eax
					not eax
					and [regs]._eax,eax
					or [regs]._eax,edx
					not eax
					shl eax, 8
					dec edi
				.endw
				pop eax
				.while (edi && eax)
					mov edx,dwCB
					and edx, eax
					not eax
					and [regs]._edx,eax
					or [regs]._edx,edx
					not eax
					shl eax, 8
					dec edi
				.endw
				invoke r0proc, offset writemsr, r0cs, addr regs
				inc regs._ecx
				mov eax,0ffh
				mov ecx,eax
			.endw
		.else
			sub eax, 0C0h	;eax = 0..3F
			sub edi, 0C0h
			sub edi, eax
			inc edi			;pages to modify
			shr eax, 3		;8 4K pages for 1 mtrr
			mov ebx, 268h
			add ebx, eax
			mov [regs]._ecx, ebx
			.while (edi)
				invoke r0proc, offset readmsr, r0cs, addr regs
				mov eax,0FFh
				.while (edi && eax)
					mov edx,dwCB
					and edx, eax
					not eax
					and [regs]._eax,eax
					or [regs]._eax,edx
					not eax
					shl eax, 8
					dec edi
				.endw
				mov eax,0FFh
				.while (edi && eax)
					mov edx,dwCB
					and edx, eax
					not eax
					and [regs]._edx,eax
					or [regs]._edx,edx
					not eax
					shl eax, 8
					dec edi
				.endw
				invoke r0proc, offset writemsr, r0cs, addr regs
				inc regs._ecx
			.endw
		.endif
		add esi, 3*2
	.endw
	ret
getcb:
	mov dx,[esi+4]
	.if (dx == "UC")
		mov edx, 00000000h
	.elseif (dx == "WC")
		mov edx, 01010101h
	.elseif (dx == "WP")
		mov edx, 05050505h
	.elseif (dx == "WT")
		mov edx, 04040404h
	.elseif (dx == "WB")
		mov edx, 06060606h
	.endif
	retn
	align 4

SetFixedMtrr endp

main proc c

local	r0cs:dword
local	dwCaps:DWORD
local	regs[80]:REGS
local	vesainfo:VESAINFO

	invoke GetCmdLine
	and eax, eax
	jz exit

;--- running on NT?

	mov ax,3306h
	int 21h
	.if (bx == 3205h)
		invoke printf, CStr("VESAMTRR will not run on NT platforms",13,10)
		jmp exit
	.endif

;--- MTRRs supported?

	mov ax,400h
	int 31h
	cmp cl,4		;must be at least a 80486
	jb nomtrr

	pushfd
	push 200000h
	popfd
	pushfd
	pop eax
	popfd
	test eax,200000h	;CPUID supported?
	jz nomtrr

	mov eax,1
	xor edx, edx
	cpuid
	.if (!(edx & 1000h))
nomtrr:
		invoke printf, CStr("MTRRs not supported",13,10)
		jmp exit
	.endif

	.if (bVesa)
		invoke GetVesaLFBAddr, 101h
		.if (!eax)
			invoke printf, CStr("cannot get VESA LFB information",13,10)
			jmp exit
		.endif
		mov dwPhysBase, eax
		invoke GetVesaInfo_, addr vesainfo
		.if (!eax)
			invoke printf, CStr("cannot get VESA video memory size",13,10)
			jmp exit
		.endif
		movzx eax, vesainfo.TotalMemory	;in 64 kB blocks
		shl eax, 16
		mov dwLFBSize, eax
	.endif            

;--- find a ring 0 code selector

	invoke GetR0CS
	.if (!eax)
		invoke printf, CStr("cannot get a ring 0 code selector",13,10)
		jmp exit
	.endif
	mov r0cs, eax

;--- read the MTRRCAP register (#FE)
;--- contains the number of MTRRs in low byte

	lea edi, regs
	mov [edi].REGS._eax, 0
	mov [edi].REGS._ecx, 0FEh
	invoke r0proc, offset readmsr, r0cs, edi
	mov eax, [edi].REGS._eax
	mov dwCaps, eax
	movzx esi, al
	.if (bStatus)
		mov ecx, CStr("is")
		test ah,4
		jnz @F
		mov ecx, CStr("is NOT")
@@:
		invoke printf, CStr("MTRRCAPS(#FE): %X (WC %s supported)",13,10), eax, ecx
	.endif

;--- read all variable MTRRs

	mov ebx, 200h
	lea edi, regs
	shl esi, 1
	.while (esi)

		mov [edi].REGS._eax, 0
		mov [edi].REGS._edx, 0
		mov [edi].REGS._ebx, 0
		mov [edi].REGS._ecx, ebx
		invoke r0proc, offset readmsr, r0cs, edi
		add edi, sizeof REGS
		inc ebx
		dec esi
	.endw

	.if (bStatus)
		lea edi, regs
		movzx esi, byte ptr [dwCaps]
		mov ebx,200h
		.while (esi)

			invoke printf, CStr("#%X: %08X.%08X  %08X.%08X"),
				ebx, [edi].REGS._edx, [edi].REGS._eax,
				[edi+sizeof REGS].REGS._edx, [edi+sizeof REGS].REGS._eax
			.if ([edi+sizeof REGS].REGS._eax & 800h)
				mov eax,[edi+sizeof REGS].REGS._eax
				mov edx,[edi+sizeof REGS].REGS._edx
				push ebx
				push esi
				mov ecx,[edi].REGS._eax
				mov ebx,[edi].REGS._edx
				call gettype
				and cx,0F000h
				and ax,0F000h
				xor eax,-1
				xor edx,-1
				add eax,ecx
				adc edx,ebx
				and edx,0Fh
				invoke printf, CStr(" (%X%08X-%X%08X, %s)"), ebx, ecx, edx, eax, esi
				pop esi
				pop ebx
			.endif
			invoke printf, CStr(13,10)
			add edi, sizeof REGS * 2
			add ebx, 2
			dec esi
		.endw
;--- display the fixed range registers as well (#250, #258-259, #268-26F)
;--- also display the default type MTRR_DEF_TYPE (#2FF)

		.if (dwCaps & 100h)	;fixed MTRRs supported?
			lea edi, regs
			mov [edi].REGS._ecx,250h
			invoke r0proc, offset readmsr, r0cs, edi
			invoke printf, CStr(13,10,"#250: %08X.%08X (FIX64K: 00000-7FFFF)",13,10), [edi].REGS._edx, [edi].REGS._eax
			mov [edi].REGS._ecx,258h
			invoke r0proc, offset readmsr, r0cs, edi
			invoke printf, CStr("#258: %08X.%08X (FIX16K: 80000-9FFFF)",13,10), [edi].REGS._edx, [edi].REGS._eax
			mov [edi].REGS._ecx,259h
			invoke r0proc, offset readmsr, r0cs, edi
			invoke printf, CStr("#259: %08X.%08X (FIX16K: A0000-BFFFF)",13,10), [edi].REGS._edx, [edi].REGS._eax
			mov ebx, 268h
			mov esi,8
			mov edi,0C0000h
			.while (esi)
				mov regs._ecx,ebx
				invoke r0proc, offset readmsr, r0cs, addr regs
				lea eax,[edi+7FFFh]
				invoke printf, CStr("#%X: %08X.%08X (FIX4K: %X-%X)",13,10), ebx, regs._edx, regs._eax, edi, eax
				add edi,8000h
				inc ebx
				dec esi
			.endw
		.endif
if 0
		.if ([dwCaps] & 10000h)	;PAT available?
			mov regs._ecx,277h
			invoke r0proc, offset readmsr, r0cs, addr regs
			invoke printf, CStr(13,10,"#277: %08X.%08X",13,10), regs._edx, regs._eax
		.endif
endif
		mov regs._ecx,2FFh
		invoke r0proc, offset readmsr, r0cs, addr regs
		.if (regs._eax & 800h)
			mov edx,CStr("MTRRs enabled, Fixed MTRRs ")
			.if (regs._eax & 400h)
				mov ecx,CStr("enabled")
			.else
				mov ecx,CStr("disabled")
			.endif
		.else
			mov edx,CStr("MTRRs disabled")
			mov ecx,CStr("")
		.endif
		invoke printf, CStr(13,10,"#2FF: %08X.%08X (%s%s)",13,10), regs._edx, regs._eax, edx, ecx
		jmp exit
	.endif

	.if (dwCaps & 100h)	;fixed MTRRs supported?
		invoke SetFixedMtrr, r0cs
	.endif

;--- scan variable MTRRs and see if there is already one for LFB

	movzx ebx, byte ptr [dwCaps]
	xor esi, esi
	lea edi, regs
	.while (ebx)
		.if ([edi+sizeof REGS].REGS._eax & 0800h)
			mov ecx, [edi].REGS._eax
			mov edx, [edi].REGS._edx
			and cx, 0F000h
			.if ((ecx == dwPhysBase) && (dl == 0))
				jmp found
			.endif
if 0
			invoke printf, CStr("msr %X+%X: %X%08X %X%08X "),
				[edi].REGS._ecx, [EDI+sizeof REGS].REGS._ecx,
				[edi].REGS._edx, [edi].REGS._eax,
				[edi+sizeof REGS].REGS._edx, [edi+sizeof REGS].REGS._eax
endif
		.elseif (!esi)
			mov esi, edi
		.endif
		add edi, 2 * sizeof REGS
		dec ebx
	.endw
	.if (!esi)
		invoke printf, CStr("all MTRRs are in use, VESA LFB is not among them",13,10)
		jmp exit
	.endif
	mov edi, esi
found:
	.if ([edi+sizeof REGS].REGS._eax & 0800h)
		mov ecx, 0
		sub ecx, dwLFBSize
		or ch,08
		mov al, byte ptr [edi].REGS._eax
		.if ((al == 1) && (ecx == [edi+sizeof REGS].REGS._eax))
			mov eax, [edi].REGS._ecx
			mov edx, [edi+sizeof REGS].REGS._ecx
			invoke printf, CStr("MSRs %X and %X already set to speed VESA LFB access",13,10), eax, edx
			jmp exit
		.endif
	.endif

;--- no MTRR for LFB has been found, write one

	.if (dwCaps & 400h)	;WC supported?
		mov eax, dwPhysBase
		mov al, 01				;set WC type
		mov [edi].REGS._eax, eax
		mov [edi].REGS._edx, 0
		mov eax, 0
		sub eax, dwLFBSize
		or ah,8					;valid entry
		mov [edi+sizeof REGS].REGS._eax, eax
		mov [edi+sizeof REGS].REGS._edx, 0Fh 
		invoke r0proc, offset writemsr, r0cs, edi
		add edi, sizeof REGS
		invoke r0proc, offset writemsr, r0cs, edi

		mov eax, [edi-sizeof REGS].REGS._ecx
		mov edx, [edi].REGS._ecx
		invoke printf, CStr("MSRs %X-%X modified",13,10), eax, edx
	.else
		invoke printf, CStr("WC memory type not supported, no MSR modified",13,10)
	.endif

exit:
;--- restore first entry in LDT if it was used
	.if (dwLDT)
		mov ebx, dwLDT
		mov edx, dword ptr dqLDT0+0
		mov ecx, dword ptr dqLDT0+4
		mov dword ptr @flat:[ebx+0], edx
		mov dword ptr @flat:[ebx+4], ecx
	.endif
	xor eax,eax
	ret
gettype:
	.if (cl == 0)
		mov esi, CStr("UC")
	.elseif (cl == 1)
		mov esi, CStr("WC")
	.elseif (cl == 4)
		mov esi, CStr("WT")
	.elseif (cl == 5)
		mov esi, CStr("WP")
	.elseif (cl == 6)
		mov esi, CStr("WB")
	.else
		mov esi, CStr("??")
	.endif
	retn

main endp

mainCRTStartup proc c

	call main
	mov ah,4ch
	int 21h

mainCRTStartup endp

	END mainCRTStartup

