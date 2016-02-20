
# this sample needs the Win32Inc include files

name = THREAD

DEBUG=0

!if $(DEBUG)
LOPTD=/DEBUG:FULL
AOPTD=-Zd -DDEBUG
!else
LOPTD=
AOPTD=
!endif

ASM = ml -c -Fo$* -coff -I\win32inc\include

LIBCOFF=..\..\Lib

LIBS=dkrnl32.lib duser32.lib

OUTDIR=.

LOPT=/OUT:$*.EXE /MAP:$*.map /SUBSYSTEM:CONSOLE /FIXED:NO /LIBPATH:$(LIBCOFF) /STUB:..\..\bin\dpmist32.bin /MERGE:.rdata=.text /MERGE:.reloc=.data
LINK=polink
MODS=$*.obj

$(OUTDIR)\$(name).exe: $*.obj
    $(LINK) $(MODS) $(LOPT) $(LIBS) 

$(OUTDIR)\$(name).obj: $(name).asm $(name).mak
     $(ASM) $(name).asm

