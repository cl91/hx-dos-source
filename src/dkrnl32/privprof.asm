
;--- implements 
;--- GetPrivateProfileStringA
;--- GetPrivateProfileSectionA
;--- WritePrivateProfileStringA

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

		option dotname

;--- file cache entry

FCENTRY	struct
pCacheMem	dd 0	;pointer to memory block (starts with file name)
dwSize		dd 0	;size of memory block
bModified	db 0
FCENTRY ends

.BASE$XA SEGMENT dword public 'DATA'
        DD offset destructor
.BASE$XA ENDS

		.data

g_cs		CRITICAL_SECTION <>        
g_fc		FCENTRY <>
g_bInit		db 0

        .CODE

ToLower proc
        cmp     al,'A'
        jc      @F
        cmp     al,'Z'
        ja      @F
        or      al,20h
@@:
        ret
        align 4
ToLower endp

;--- check if 2 strings are equal

checkstrings   proc uses esi

check_0:
        mov     al,[edi]
        call    ToLower
        mov     ah,al
        mov     al,[esi]
        call    ToLower
        inc     esi
        inc     edi
        cmp     al,ah
        jz      check_0
        dec     esi
        dec     edi
        mov     al,[esi]
        ret
        align 4
checkstrings   endp

;--- compare 2 strings case-sensitive and 
;--- edi is terminated by a '"'

checkstrings2   proc uses esi

check_0:
        mov     al,[edi]
        mov     ah,al
        mov     al,[esi]
        inc     esi
        inc     edi
        cmp     al,ah
        jz      check_0
        .if (ah == '"')
        	mov ah, [edi]
        .else
	        dec edi
        .endif
        dec     esi
        mov     al,[esi]
        ret
        align 4
checkstrings2   endp

skipline proc
nextchar:
        mov     al, [edi]
        cmp     al, 10
        jz      done
        cmp     al, 0
        jz      doneall
        inc     edi
        jmp     nextchar
done:
        inc     edi
doneall:
        ret
        align 4
skipline endp

skipline2 proc
        .while (byte ptr [esi])
            lodsb
            .break .if (al == 10)
        .endw
        ret
        align 4
skipline2 endp

copykeyname proc

        dec esi
        mov ebx, ecx
        mov edx, edi
next:
        lodsb
        cmp al,'='
        jz iskey
        cmp al,13
        jz done
        cmp al, 0
        jz done2
        stosb
        dec ecx
        jnz next
done2:
        dec esi
done:
        mov edi, edx
        mov ecx, ebx
        jmp exit
iskey:
        mov al,0
        stosb
        dec ecx
exit:
        ret
        align 4
copykeyname endp

;--- copy all keys in a section to edi, max size ecx
;--- end is indicated by 2 00 bytes

getallkeys proc uses ebx
        jecxz   done
        dec ecx
        .while (ecx && byte ptr [esi])
            lodsb
            .if (al == ';')
                ;
            .elseif (al == 13)
            .else
                call copykeyname
            .endif
            call skipline2
        .endw
        mov al,0
        stosb
done:
        ret
        align 4
getallkeys  endp


copysectionname proc
next:
        lodsb
        cmp al,']'
        jz done
        cmp al,13
        jz done
        cmp al, 0
        jz done2
        stosb
        dec ecx
        jnz next
        dec edi
        inc ecx
        jmp done
done2:
        dec esi
done:

        mov al,0
        stosb
        dec ecx
        ret
        align 4
copysectionname endp

;--- copy all section names to edi, max size ecx
;--- end is indicated by 2 00 bytes


getallsections proc

        jecxz   done
        dec ecx
        .while (ecx && byte ptr [esi])
            lodsb
            .if (al == '[')
                call copysectionname
            .endif
            call skipline2
        .endw
        mov al,0
        stosb
done:
        ret
        align 4
getallsections  endp


;--- section -> esi
;--- file -> edi

searchsection   proc

        mov ecx, -1
        .while (byte ptr [edi])
            .if (byte ptr [edi] == '[')
                inc     edi
                call    checkstrings
                cmp     ax, ']' * 100h ; ah==']' && al==0?
                jz		done
            .endif
            call skipline
        .endw
error:
        stc
        ret
done:
		call skipline
        clc
        ret
        align 4

searchsection endp


;--- esi -> entry
;--- edi -> file (points directly behind section name)

searchentry     proc

        mov ecx, -1
        .while (byte ptr [edi])
            .break .if (byte ptr [edi] == '[')
            mov al, [edi]
            .if (al == '"')
            	inc edi
	            call    checkstrings2
            .else
	            call    checkstrings
            .endif
            and     al,al
            jnz     @F
            cmp     ah,'='
            jz      done
@@:            
            call skipline
        .endw
error:
        stc
        ret
done:
        ret
        align 4
searchentry     endp

init proc
		.if (!g_bInit)
        	mov g_bInit, 1
        	invoke InitializeCriticalSection, addr g_cs
        .endif
        invoke EnterCriticalSection, addr g_cs
		ret
        align 4
init endp


DestroyFileCacheEntry proc public uses ebx esi edi pFC:ptr FCENTRY
		mov edi, pFC
        .if ([edi].FCENTRY.pCacheMem)
			.if ([edi].FCENTRY.bModified)
    	    	mov esi, [edi].FCENTRY.pCacheMem
		        invoke CreateFileA, esi, GENERIC_WRITE, 0, 0, CREATE_ALWAYS,\
    	                FILE_ATTRIBUTE_NORMAL, 0
	        	.if (eax != -1)
    	        	mov ebx, eax
        	        invoke lstrlen, esi
	                lea esi, [eax+esi+1]
    	            invoke lstrlen, esi
        	        push 0
	                mov ecx, esp
			        invoke WriteFile, ebx, esi, eax, ecx, 0
        	        pop ecx
	        		invoke SetEndOfFile, ebx
    	            invoke CloseHandle, ebx
        	        mov [edi].FCENTRY.bModified, 0
	            .endif
    	    .endif
	      	invoke VirtualFree, [edi].FCENTRY.pCacheMem, 0, MEM_RELEASE
    	    mov [edi].FCENTRY.pCacheMem, 0
        .endif
        ret
        align 4
DestroyFileCacheEntry endp        

;--- modifies edi

IsFileCached proc pszFile:ptr BYTE

		xor eax, eax
        mov edi, offset g_fc
		.if ([edi].FCENTRY.pCacheMem)
        	invoke lstrcmpi, [edi].FCENTRY.pCacheMem, pszFile
            .if (!eax)
            	invoke lstrlen, [edi].FCENTRY.pCacheMem
                mov edi, [edi].FCENTRY.pCacheMem
                lea edi, [edi+eax+1]
            .else
            	invoke DestroyFileCacheEntry, edi
                xor eax, eax
            .endif
        .endif
        ret
        align 4
        
IsFileCached endp

;--- out: edi=start of file buffer
;--- g_fc.pCacheMem != null

CacheFile proc pszFile:ptr BYTE

local	dwSize:dword

		invoke CreateFileA, pszFile, GENERIC_READ, 0, 0, OPEN_EXISTING,\
						FILE_ATTRIBUTE_NORMAL, 0
		mov 	ebx,eax
		cmp 	eax, -1
		jz		exit
		invoke	GetFileSize, ebx, 0
		cmp 	eax, -1
		jz		@F
		mov		dwSize, eax
		invoke	lstrlen, pszFile
		inc		eax
		mov 	esi, eax
		inc 	eax
		add 	eax, dwSize
        add		eax, 4000h
        and		ax, 0F000h
        mov		g_fc.dwSize, eax
		invoke	VirtualAlloc, 0, eax, MEM_COMMIT, PAGE_READWRITE
		and 	eax, eax
		jz		@F
		mov 	g_fc.pCacheMem, eax
		lea		edi, [esi+eax]
        push	0
        mov		eax, esp
		invoke	ReadFile, ebx, edi, dwSize, eax, 0
        pop		ecx
		mov 	byte ptr [edi+ecx],0
        invoke	lstrcpy, g_fc.pCacheMem, pszFile
@@: 		
		invoke	CloseHandle, ebx
exit:   
		mov     eax, g_fc.pCacheMem
		ret
        align 4
CacheFile endp

;--- cases:
;--- lpAppName == NULL: copy all section names to buffer
;--- lpKeyName == NULL: copy all key names to buffer
		
GetPrivateProfileStringA proc public uses esi edi ebx lpAppName:ptr byte,
        lpKeyName:ptr byte, lpDefault:ptr byte, retbuff:ptr byte, 
        bufsize:dword, filename:ptr byte

local   rc:dword
local	dwRead:dword
local	dwSize:dword
local	bString:BYTE


        xor     eax,eax
        mov     rc,eax
        mov		bString,al
        call    init

		invoke IsFileCached, filename
        .if (!eax)
        	invoke CacheFile, filename
        .endif
        and eax, eax
        jz copydefault

        mov     esi,lpAppName         ;search section
        .if (esi)
            call    searchsection
            jc      copydefault
        .else
            mov     esi, edi
            mov     ecx,bufsize
            mov     edi,retbuff
            call    getallsections
            sub		edi, retbuff
            mov		rc, edi
;            mov     rc, eax
            jmp     exit
        .endif

;		@strace	<"GetPrivateProfileStringA(", lpAppName, "): section found">

        mov     esi,lpKeyName
        .if (esi)
            call    searchentry
            jc      copydefault
            jmp     copyvalue
        .else
            mov     esi, edi
            mov     ecx,bufsize
            mov     edi,retbuff
            call    getallkeys
            sub		edi, retbuff
            mov		rc, edi
;            mov     rc, eax
        .endif

        jmp     exit
getescapechar:
		lodsb
        .if (al == 'r')
        	mov al,13
        .elseif (al == 't')
        	mov al,9
        .elseif (al == 'n')
        	mov al,10
        .endif
        retn
copyvalue:
		mov		esi, edi
        inc     esi
        mov     edi, retbuff
        mov     ecx, bufsize
        jecxz   cd2
        mov al,[esi]
        mov ah,0
        .if (al == '"')
        	inc esi
            mov ah, al
            mov bString,1
        .endif
        dec ecx
nextvaluechar:
        lodsb
        cmp     al,13
        jz      copyvaluedone
		cmp		ax,'"'* 100h + '\'
        jnz     @F
        call	getescapechar
		jmp		storechar        
@@:        
        cmp		ax,'""'			;end of string?
        jnz 	storechar
        cmp		al,[esi]
        jnz		copyvaluedone
        inc		esi
storechar:
        stosb
        and     al,al
        loopnz  nextvaluechar
copyvaluedone:
        mov al,0
        stosb
        sub edi, retbuff
        dec edi
        mov rc, edi
        jmp exit

copydefault:
        mov     esi, lpDefault
        mov     edi, retbuff
        mov     ecx, bufsize
        jecxz   cd2
cd1:
        lodsb
        stosb
        and al,al
        loopnz  cd1
        .if (!ecx)
            dec edi
            mov al,0
            stosb
        .endif
        sub edi, retbuff
        dec edi
        mov rc, edi
cd2:
        
exit:
        invoke LeaveCriticalSection, addr g_cs
        mov     eax,rc
ifdef _DEBUG
		mov  ecx, lpAppName
		.if (!ecx)
			mov ecx, CStr("NULL")
		.endif
		mov  edx, lpKeyName
		.if (!edx)
			mov edx, CStr("NULL")
		.endif
		@strace	<"GetPrivateProfileStringA(", &ecx, ", ", &edx,  ", ", lpDefault, ", ", retbuff, ", ", bufsize, ", ", filename, ")=", eax>
endif
		mov dl,bString
        ret
        align 4

GetPrivateProfileStringA endp

;--- this version copies all key=value pairs of a section into the buffer

GetPrivateProfileSectionA proc public uses esi edi ebx lpAppName:ptr BYTE,
        lpReturnedString:ptr BYTE, nSize:DWORD, lpFileName:ptr byte

local	rc:DWORD

		xor eax, eax
        mov rc, eax
        call    init
		invoke IsFileCached, lpFileName
        .if (!eax)
        	invoke CacheFile, lpFileName
        .endif
        mov     esi,lpAppName         ;search section
        call    searchsection
        jc exit
		mov 	esi, edi
		mov 	ecx,nSize
		mov 	edi,lpReturnedString
        jecxz	@F
        dec		ecx		;room for terminating 00
        .while (ecx)
        	lodsb
            .break .if (!al)
            .break .if (al == '[')
            .if ((al == ';') || (al <= ' '))
            	call skipline2
            .else
            	stosb
	            dec ecx
                .while (ecx)
                	lodsb
                    .continue .if (al == 13)
                    .if (al == 10)
                    	mov al,0
                    .endif
                    stosb
                    dec ecx
                    .break .if (al == 0)
                .endw
            .endif
        .endw
        mov al,0
        mov [edi],al	;do not count the terminating 00
@@:        
		sub		edi, lpReturnedString
		mov		rc, edi
exit:

        invoke LeaveCriticalSection, addr g_cs
        mov     eax,rc
		@strace	<"GetPrivateProfileSectionA(", lpAppName, ", ", lpReturnedString, ", ", nSize, ", ", lpFileName, ")=", eax>
        ret
        align 4

GetPrivateProfileSectionA endp

;--- lpAppName might be NULL
;--- lpKeyName might be NULL
;--- lpValue might be NULL

WritePrivateProfileStringA proc public uses esi edi ebx lpAppName:ptr byte,
            lpKeyName:ptr byte, lpValue:ptr byte, filename:ptr byte
 
local   rc:dword
local	dwSize:dword
local	dwAppSize:dword
local	dwKeySize:dword
local	dwValueSize:dword

        xor		eax, eax
        mov     rc,eax
        mov		dwKeySize, eax
        mov		dwValueSize, eax
        call    init
        
        .if (lpAppName)
        	invoke lstrlen, lpAppName
            mov dwAppSize, eax
        .endif
        .if (lpKeyName)
        	invoke lstrlen, lpKeyName
            mov dwKeySize, eax
        .endif
        .if (lpValue)
        	invoke lstrlen, lpValue
            mov dwValueSize, eax
        .endif

		invoke IsFileCached, filename
        .if (!eax)
        	invoke CacheFile, filename
        .else
        	invoke lstrlen, edi
            lea eax, [eax+edi+1]
            sub eax, g_fc.pCacheMem
            add eax, 1000h				;let's assume an entry is < 4 kB!
            cmp eax, g_fc.dwSize		;is there enough free space?
            jc @F
            invoke DestroyFileCacheEntry, addr g_fc
            invoke CacheFile, filename
@@:         
        .endif
        and eax, eax
        jz exit

        mov     esi,lpAppName
        .if (esi)
            call    searchsection
            jc      insertnewsection
if 0;def _DEBUG
            @strace <"section found at ", edi>
endif       
        .else
;-------------------------------- all three entries = NULL -> flush cache
            .if ((!lpKeyName) && (!lpValue))
            	invoke DestroyFileCacheEntry, offset g_fc
                jmp done
            .endif
;-------------------------------- this is an error
            jmp done
        .endif

        mov     esi,lpKeyName
        .if (esi)
            call    searchentry
            jc      insertnewkey
if 0;def _DEBUG
            @strace <"key found at ", edi>
endif       
        .else
;-------------------------------- delete this section
            jmp deletesection
        .endif

        mov     esi,lpValue
        .if (!esi)
            jmp deletekey
        .endif

replacevalue:
        inc     edi					;skip "="
        xor     ecx,ecx
        .while (1)
            mov al, [edi+ecx]
            .break .if ((al == 0) || (al == 13))
            inc ecx
        .endw
;---------------------------------------- if value hasnt changed, do nothing
        .if (ecx == dwValueSize)
        	pushad
            repz cmpsb
            popad
			.if (ZERO?)
            	mov rc,1
                jmp done
        	.endif
        .endif
        mov esi, dwValueSize
        add esi, edi
        push edi
        lea edi, [edi+ecx]
        invoke  lstrlen, edi		;get length of rest of profile file
        inc eax						;include terminating 0?
        invoke  RtlMoveMemory, esi, edi, eax
        pop edi
        mov esi, lpValue
        mov ecx, dwValueSize
        rep movsb
        mov rc, 1					;no need to return size of string here
        jmp rewritefile
deletesection:
;------------------------------ not implemented yet
        jmp     done
deletekey:
;------------------------------ not implemented yet
        jmp     done
insertnewsection:
        @strace <"insert new section">
        .if (!lpKeyName)
;------------------------------ section does not exist and should be deleted
            jmp done
        .endif
        mov ax, 0A0Dh
        stosw
        mov     al,'['
        stosb
        mov     esi, lpAppName
        .while (byte ptr [esi])
            movsb
        .endw
        mov     al,']'
        stosb
        mov     ax,0A0Dh
        stosw
        mov byte ptr [edi],0
insertnewkey:
        @strace <"insert new key">

        mov rc, 1

        .if (!lpValue)
            jmp done
        .endif
        mov     esi, lpKeyName
        .while (byte ptr [esi])
            movsb
        .endw
        mov al,'='
        stosb
        mov     esi, lpValue
        .while (byte ptr [esi])
            movsb
        .endw
        mov     ax,0A0Dh
        stosw
        mov byte ptr [edi],0
rewritefile:
		mov g_fc.bModified, 1
done:

exit:
        invoke LeaveCriticalSection, addr g_cs
        mov     eax,rc
ifdef _DEBUG
        push ebx
		mov  ecx, lpAppName
		.if (!ecx)
			mov ecx, CStr("NULL")
		.endif
		mov  edx, lpKeyName
		.if (!edx)
			mov edx, CStr("NULL")
		.endif
		mov  ebx, lpValue
		.if (!ebx)
			mov ebx, CStr("NULL")
		.endif
		@strace	<"WritePrivateProfileStringA(", ecx, ", ", edx, ", ", ebx, ", ", filename, ")=", eax>
        pop ebx
endif
        ret
        align 4
        
WritePrivateProfileStringA endp

destructor proc
		@strace <"private profile destructor enter">
	  	invoke DestroyFileCacheEntry, offset g_fc
		ret
destructor endp


        end

