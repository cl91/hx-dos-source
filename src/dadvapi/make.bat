@echo off
rem alternative way to create DADVAPI.DLL
rem uses JWasm, MS lib and MS link
cd RELEASE
del *.obj
jwasm.exe -coff -nologo -Sg -D_ADVAPI32_=1 -I..\..\..\Include -D?FLAT=1 -Fl ..\*.asm 
lib /NOLOGO *.obj /OUT:DADVAPIS.LIB
lib /NOLOGO DADVAPIS.LIB /REMOVE:DADVAPI.OBJ /OUT:DADVAPIS.LIB
link /NOLOGO /LIBPATH:..\..\..\Lib DADVAPI.obj DADVAPIS.LIB DKRNL32.LIB /DLL /OUT:DADVAPI.DLL /DEF:..\DADVAPI.DEF /MAP /OPT:NOWIN98
cd ..
