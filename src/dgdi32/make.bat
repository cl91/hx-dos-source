@echo off
rem alternative way to create DGDI32.DLL
rem uses JWasm, MS lib and MS link
del RELEASE\*.obj
jwasm.exe -coff -nologo -Sg -D_GDI32_=1 -I..\..\Include -D?FLAT=1 -Fo=RELEASE\ -Fl=RELEASE\ *.asm
cd RELEASE
lib /NOLOGO *.obj /OUT:DGDI32S.LIB
lib /NOLOGO DGDI32S.LIB /REMOVE:DGDI32.OBJ /OUT:DGDI32S.LIB
link /NOLOGO /LIBPATH:..\..\..\Lib DGDI32.obj DGDI32S.LIB DKRNL32.LIB /DLL /OUT:DGDI32.DLL /DEF:..\DGDI32.DEF /MAP /OPT:NOWIN98
cd ..
