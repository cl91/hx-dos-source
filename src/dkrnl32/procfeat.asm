
;--- implements IsProcessorFeaturePresent
;--- this function is not supported by Win9x!

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

if ?PROCFEAT

;--- cpuid feature flags
;      1 FPU:  FPU is integrated
;      2 VME:  supports CR4 VME/PVI, EFL VIF/VIP
;      4 DE:   supports i/o breakpoints + CR4 DE
;      8 PSE:  4MB page size supported + CR4 PSE
;     10 TSC:  support for RDTSC + CR4 TSD
;     20 MSR:  support for RDMSR/WRMSR
;     40 PAE:  physical address extension + CR4 PAE
;     80 MCE:  machine check exceptions + CR4 MCE
;    100 CX8:  CMPXCHG8B supported
;    200 APIC: on chip APIC exists and enabled
;   1000 MTRR: memory type range registers supported
;   2000 PGE:  support for CR4 PGE
;   4000 MCA:  MCA_GAP MSR supported
;   8000 CMOV: CMOV + FCMOV/FCOMI supported
; 800000 MMX:  MMX supported
;2000000 XMMI: XMMI supported

CPUID_RDTSC_SUPP	equ 0000010h
CPUID_CX8_SUPP		equ 0000100h
CPUID_MMX_SUPP		equ 0800000h
CPUID_XMMI_SUPP		equ 2000000h

	option dotname

.BASE$IA SEGMENT dword public 'DATA'
	DD offset Install
.BASE$IA      ENDS

	.data

g_flags dd 0        
g_bInit	db 0        
g_cpu	db 0
g_step	db 0

	.code

checkcpuid proc uses ebx

	pushfd
	push 200000h		;push ID flag
	popfd
	pushfd
	pop  eax
	test eax,200000h	;is it set now?
	mov  al,00
	jz checkcpuid_ex
	push 1
	pop eax
	.586
	cpuid				;returns cpu in AH, step in AL, flags in EDX
	.386
	popfd
	mov [g_cpu],ah		;cpu
	mov [g_step],al 	;mask/stepping
	mov [g_flags],edx	;feature flags
	clc
	ret
checkcpuid_ex:
	popfd
	stc
	ret
	align 4

checkcpuid endp

Install proc
	@noints
	invoke checkcpuid
	@restoreints
	ret
	align 4
Install endp

IsProcessorFeaturePresent proc export dwFeature:dword

	mov ecx, dwFeature
	xor eax, eax
	.if (ecx == PF_COMPARE_EXCHANGE_DOUBLE)
		test g_flags, CPUID_CX8_SUPP
		setnz al
	.elseif (ecx == PF_MMX_INSTRUCTIONS_AVAILABLE)
		test g_flags, CPUID_MMX_SUPP
		setnz al
	.elseif (ecx == PF_XMMI_INSTRUCTIONS_AVAILABLE)
		test g_flags, CPUID_XMMI_SUPP
		setnz al
	.elseif (ecx == PF_RDTSC_INSTRUCTION_AVAILABLE)
		test g_flags, CPUID_RDTSC_SUPP
		setnz al
	.endif
	@strace <"IsProcessorFeaturePresent(", dwFeature, ")=", eax>
	ret

IsProcessorFeaturePresent endp

endif

	end
