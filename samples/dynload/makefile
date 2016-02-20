
# nmake makefile

APPNAME=DYNLOADA
DLLNAME=DYNLOADD

AS=ml.exe 
AOPTA=-c -coff -nologo -Fo$* -I..\..\Include
AOPTD=-c -coff -nologo -Fo$* -I..\..\Include
LINK=link.exe
LOPTA= /NOLOGO /MAP /SUBSYSTEM:CONSOLE /FIXED:NO /STUB:..\..\bin\dpmist32.bin 
LOPTD= /NOLOGO /MAP /DLL /DEF:$(DLLNAME).def

# use (w)vsprintf included in the static coff lib duser32s.lib
# this avoids having to load duser32.dll (and dkrnl32.dll)
LIBSA=..\..\Lib\duser32s.lib
LIBSD=..\..\Lib\duser32s.lib

ALL: $(APPNAME).EXE $(DLLNAME).DLL

# use the /MERGE linker option to put constant data in .text section

$(APPNAME).EXE: $*.obj Makefile
    $(LINK) $*.obj $(LOPTA) $(LIBSA) /MERGE:.rdata=.text
    ..\..\bin\patchPE $*.exe

$(APPNAME).OBJ: $(APPNAME).asm
    $(AS) $(AOPTA) $(APPNAME).asm

$(DLLNAME).DLL: $*.obj $(DLLNAME).def Makefile
    $(LINK) $*.obj $(LOPTD) $(LIBSD) /MERGE:.rdata=.text

$(DLLNAME).OBJ: $(DLLNAME).asm
    $(AS) $(AOPTD) $(DLLNAME).asm

