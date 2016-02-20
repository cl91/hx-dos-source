@echo off
rem alternative way to create DUSER32.DLL
rem uses JWasm, MS lib, MS RC and MS link
del RELEASE\*.obj
jwasm.exe -coff -nologo -Sg -D_USER32_=1 -I..\..\Include -D?FLAT=1 -Fl=RELEASE\ -Fo=RELEASE\ *.asm
cd RELEASE
lib /NOLOGO *.obj /OUT:DUSER32S.LIB
lib /NOLOGO DUSER32S.LIB /REMOVE:DUSER32.OBJ /OUT:DUSER32S.LIB
rc -r -fo duser32.res ..\duser32.rc
link /NOLOGO /LIBPATH:..\..\..\Lib DUSER32.obj DUSER32S.LIB DUSER32.RES ..\LibCoff\LibC32u.lib DKRNL32.LIB DGDI32.LIB /DLL /OUT:DUSER32.DLL /DEF:..\DUSER32.DEF /MAP /OPT:NOWIN98
cd ..
