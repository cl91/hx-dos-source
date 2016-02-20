
		.386
if ?FLAT
		.MODEL FLAT, stdcall
else
		.MODEL SMALL, stdcall
endif
		option casemap:none
        option proc:private

		include winbase.inc
		include winuser.inc
        include wingdi.inc
		include wincon.inc
        include macros.inc
        include duser32.inc

;--- functions implemented:

;--- CallWindowProcW
;--- CreateWindowExW
;--- DefWindowProcW
;--- FindWindowW
;--- FindWindowExW
;--- GetWindowLongW
;--- GetWindowTextW
;--- GetWindowTextLengthW
;--- SetWindowLongW
;--- SetWindowTextW

		.CODE

CreateWindowExW proc public uses ebx dwExStyle:dword,lpszClass:dword,
							lpszName:dword,dwStyle:dword,
							x:dword,y:dword,cx_:dword,cy:dword,
							hwndParent:dword,hMenu:dword,
							hInstance:dword,lpCreateParams:dword

		mov eax, lpszClass
        call ConvertWStr
        mov ebx, eax
        mov eax, lpszName
        call ConvertWStr
        invoke CreateWindowExA, dwExStyle, ebx, eax, dwStyle,\
        	x, y, cx_, cy, hwndParent, hMenu, hInstance, lpCreateParams
		@strace	<"CreateWindowExW()=", eax>
		ret
        align 4
        
CreateWindowExW endp

GetWindowTextW proc public hWnd:dword, pText:ptr byte, nSize:dword

		sub esp,nSize
        mov edx, esp
		invoke GetWindowTextA, hWnd, edx, nSize
        .if (eax)
        	mov edx, esp
        	invoke ConvertAStrN, edx, pText, nSize
        .endif
		@strace	<"GetWindowTextW(", hWnd, ", ", pText, ", ", nSize, ")=", eax>
		ret
        align 4
GetWindowTextW endp

SetWindowTextW proc public hWnd:HWND, pText:ptr WORD
		mov eax, pText
        call ConvertWStr
        invoke SetWindowTextA, hWnd, eax
		@strace	<"SetWindowTextW(", hWnd, ", ", pText, ")=", eax>
		ret
        align 4
SetWindowTextW endp

GetWindowTextLengthW proc public hWnd:dword
		invoke GetWindowTextLengthA, hWnd
		@strace	<"GetWindowTextLengthW(", hWnd,")=",eax>
		ret
        align 4
GetWindowTextLengthW endp

DefWindowProcW proc public hWnd:dword,message:dword,wParam:dword,lParam:dword

		invoke	DefWindowProcA, hWnd, message, wParam, lParam
		@strace	<"DefWindowProcW(", hWnd, ", ", message, ", ", wParam, ", ", lParam, ")=", eax>
        ret
        align 4
DefWindowProcW endp

GetWindowLongW proc public hWnd:HWND, nIndex:dword

		invoke GetWindowLongA, hWnd, nIndex
		@strace <"GetWindowLongW(", hWnd, ", ", nIndex, ")=", eax> 
        ret
        align 4
GetWindowLongW endp

SetWindowLongW proc public hWnd:HWND, nIndex:dword, dwNewLong:dword
		invoke SetWindowLongW, hWnd, nIndex, dwNewLong
		@strace	<"SetWindowLongW(", hWnd, ", ", nIndex, ", ", dwNewLong, ")=", eax>
        ret
        align 4
SetWindowLongW endp

protoWNDPROC typedef proto :DWORD, :DWORD, :DWORD, :DWORD
LPFNWNDPROC typedef ptr protoWNDPROC

CallWindowProcW proc public lpPrevWndProc:LPFNWNDPROC, hWnd:HWND, msg:DWORD, wParam:DWORD, lParam:DWORD
		@strace	<"CallWindowProcW(", lpPrevWndProc, ", ", hWnd, ", ", msg, ", ", wParam, ", ", lParam, ")">
        invoke lpPrevWndProc, hWnd, msg, wParam, lParam
        ret
        align 4
CallWindowProcW endp

FindWindowW proc public uses ebx lpClassName:ptr BYTE, lpWindowName:ptr BYTE

		mov eax, lpClassName
        call ConvertWStr
		mov ebx, eax
        mov eax, lpWindowName
        call ConvertWStr
        invoke FindWindowA, ebx, eax
ifdef _DEBUG        
		mov ecx, lpClassName
        and ecx, ecx
        jnz @F
        mov ecx, CStr("NULL")
@@:        
		mov edx, lpWindowName
        and edx, edx
        jnz @F
        mov edx, CStr("NULL")
@@:        
		@strace	<"FindWindowW(", &ecx , ", ", &edx, ")=", eax>
endif        
		ret
        align 4
FindWindowW endp

FindWindowExW proc public uses ebx hwndParent:DWORD, hwndChildAfter:DWORD, lpClassName:ptr WORD, lpWindowName:ptr WORD
		mov eax, lpClassName
        call ConvertWStr
		mov ebx, eax
        mov eax, lpWindowName
        call ConvertWStr
       	invoke FindWindowExA, hwndParent, hwndChildAfter, ebx, eax
		@strace	<"FindWindowExW(", hwndParent, ", ", hwndChildAfter, ", ", lpClassName , ", ", lpWindowName, ")=", eax>
		ret
        align 4
FindWindowExW endp

		end

