@echo off
rem alternative way to create DGDI32.DLL
rem uses JWasm, MS lib and MS link
cd RELEASE
del *.obj
jwasm.exe -coff -nologo -Sg -D_GDI32_=1 -I..\..\..\Include -D?FLAT=1 -Fl ..\*.asm 
lib /NOLOGO *.obj /OUT:DGDI32S.LIB
lib /NOLOGO DGDI32S.LIB /REMOVE:DGDI32.OBJ /OUT:DGDI32S.LIB
link /NOLOGO /LIBPATH:..\..\..\Lib DGDI32.obj DGDI32S.LIB DKRNL32.LIB /DLL /OUT:DGDI32.DLL /DEF:..\DGDI32.DEF /MAP /OPT:NOWIN98
cd ..
