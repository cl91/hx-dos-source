
# NMAKE makefile to create PATCHPE.EXE
# uses JWasm

!include <..\dirs>

!ifndef DEBUG
DEBUG=0
!endif

!if $(DEBUG)
OUTDIR=DEBUG
!else
OUTDIR=RELEASE
!endif

PGM=PATCHPE

ALL: $(OUTDIR) $(OUTDIR)\$(PGM).EXE

$(OUTDIR):
	@mkdir $(OUTDIR)

!if 0

LINK=jwlink.exe

!ifndef MASM
MASM=0
!endif

!if $(MASM)
ASM=@ml -c -nologo -Sg -Fl$* -Fo$* -I$(INC32DIR)
!else
ASM=@jwasm -c -nologo -Sg -Fl$* -Fo$* -I$(INC32DIR)
!endif

$(OUTDIR)\$(PGM).EXE: $*.obj makefile
	@$(LINK) @<<
sys dos
file $*.obj
name $*.EXE
op map=$*.MAP
<<
!if $(DEBUG)==0
	@copy $*.EXE ..\..\Bin\*.* >NUL
!endif

$(OUTDIR)\$(PGM).obj: $(PGM).asm makefile
	$(ASM) $(PGM).asm

!else

$(OUTDIR)\$(PGM).EXE: $(PGM).asm makefile
	@jwasm -mz -c -nologo -Sg -Fl$* -Fo$*.EXE -I$(INC32DIR) $(PGM).asm
!if $(DEBUG)==0
	@copy $*.EXE ..\..\Bin\*.* >NUL
!endif

!endif

clean:
	@del $(OUTDIR)\*.exe
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.lst
