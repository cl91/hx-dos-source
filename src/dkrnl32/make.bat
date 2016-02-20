@echo off
rem alternative way to create DKRNL32.DLL
rem uses JWasm, MS lib and MS link
cd RELEASE
del *.obj
copy ..\..\NTLFNHLP\RELEASE\int21lfn.obj .
jwasm.exe -coff -nologo -Sg -D_KERNEL32_=1 -I..\..\..\Include -D?FLAT=1 -Fl ..\*.asm 
lib /NOLOGO *.obj /OUT:DKRNL32S.LIB
lib /NOLOGO DKRNL32S.LIB /REMOVE:DKRNL32.OBJ /OUT:DKRNL32S.LIB
link /NOLOGO DKRNL32.obj DKRNL32S.LIB /DLL /OUT:DKRNL32.DLL /DEF:..\DKRNL32.DEF /MAP /MERGE:.BASE=.data /OPT:NOWIN98
cd ..
cd SBEMU
jwasm.exe -coff -nologo -Sg -D_KERNEL32_=1 -I..\..\..\Include -D?FLAT=1 -Fl -D?DIRECTDISP=1 ..\thread.asm ..\thread3.asm
copy ..\RELEASE\DKRNL32S.LIB .
lib /NOLOGO DKRNL32S.LIB THREAD.OBJ THREAD3.OBJ /OUT:DKRNL32S.LIB
link /NOLOGO ..\RELEASE\DKRNL32.obj DKRNL32S.LIB /DLL /OUT:DKRNL32.DLL /DEF:..\DKRNL32.DEF /MAP /MERGE:.BASE=.data /OPT:NOWIN98
cd ..
