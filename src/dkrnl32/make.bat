@echo off
rem alternative way to create DKRNL32.DLL
rem uses JWasm, MS lib and MS link
del RELEASE\*.obj
copy ..\NTLFNHLP\RELEASE\int21lfn.obj RELEASE\
jwasm.exe -zze -coff -nologo -Sg -D_KERNEL32_=1 -I..\..\Include -D?FLAT=1 -Fl=RELEASE\ -Fo=RELEASE\ *.asm
cd RELEASE
lib /NOLOGO *.obj /OUT:DKRNL32S.LIB
lib /NOLOGO DKRNL32S.LIB /REMOVE:DKRNL32.OBJ /OUT:DKRNL32S.LIB
link /NOLOGO DKRNL32.obj DKRNL32S.LIB /DLL /OUT:DKRNL32.DLL /DEF:..\DKRNL32.DEF /MAP /MERGE:.BASE=.data /OPT:NOWIN98
cd ..
jwasm.exe -coff -nologo -Sg -D_KERNEL32_=1 -I..\..\Include -D?FLAT=1 -Fl=SBEMU\ -Fo=SBEMU\ -D?DIRECTDISP=1 thread.asm thread3.asm
cd SBEMU
copy ..\RELEASE\DKRNL32S.LIB .
lib /NOLOGO DKRNL32S.LIB THREAD.OBJ THREAD3.OBJ /OUT:DKRNL32S.LIB
link /NOLOGO ..\RELEASE\DKRNL32.obj DKRNL32S.LIB /DLL /OUT:DKRNL32.DLL /DEF:..\DKRNL32.DEF /MAP /MERGE:.BASE=.data /OPT:NOWIN98
cd ..
