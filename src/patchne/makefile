
!include <..\dirs>

!ifndef DEBUG
DEBUG=0
!endif

!if $(DEBUG)
OUTDIR=DEBUG
!else
OUTDIR=RELEASE
!endif

PGM=PATCHNE

!ifndef MASM
MASM=0
!endif

# the Digital Mars OMF linker is used here because it produces small binaries,
# but the MS OMF linker, TLINK or WLINK should work as well

#LINK=link16.exe
LINK=$(DMCDIR)\link.exe
!if $(MASM)
ASM=@ml -c -nologo -Sg -Fl$* -Fo$* -I$(INC32DIR)
!else
ASM=@jwasm -c -nologo -Sg -Fl$* -Fo$* -I$(INC32DIR)
!endif
MODS=
LIBS=

LOPTS=$(XLOPTS)/ONE:NOE/NOE/MAP:FULL/NON/FAR

ALL: $(OUTDIR) $(OUTDIR)\$(PGM).EXE

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(PGM).EXE: $*.obj makefile
    $(LINK) $* $(MODS) $(LOPTS),$*.EXE,$*.MAP,$(LIBS);
!if $(DEBUG)==0
    @copy $*.EXE ..\..\Bin\*.* >NUL
!endif

$(OUTDIR)\$(PGM).obj: $(PGM).asm makefile
    $(ASM) $(PGM).asm

clean:
	@del $(OUTDIR)\*.exe
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.lst
