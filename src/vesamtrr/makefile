
NAME=VESAMTRR

!include <..\dirs>

OUTDIR=RELEASE

!ifndef MASM
MASM=0
!endif

ASMOPT=-c -coff -Sg -Fl$* -Fo$* -D?FLAT=1 -I$(INC32DIR)
!if $(MASM)
ASM=@ml.exe $(ASMOPT) 
!else
ASM=@jwasm.exe $(ASMOPT) 
!endif

LINK=polink
LIBS= ..\..\Lib\duser32s.lib
LOPTS= /SUBSYSTEM:CONSOLE /OPT:NOWIN98 /FIXED:NO /STUB:..\..\Bin\LoadPE.bin /STACK:0x4000

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).EXE

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).EXE: $*.obj Makefile
    $(LINK) @<<
$*.obj $(LOPTS) /OUT:$*.EXE /MAP:$*.MAP $(LIBS)
<<
	..\..\Bin\PatchPe $*.exe

$(OUTDIR)\$(NAME).obj: $(NAME).asm Makefile
    $(ASM) $(NAME).asm

clean:
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.exe
	@del $(OUTDIR)\*.map

