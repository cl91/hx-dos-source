
# NMake makefile, creates VESAMTRR.EXE
# tools used:
# - JWasm
# - WLink

NAME=VESAMTRR

!include <..\dirs>

OUTDIR=RELEASE

!ifndef MASM
MASM=0
!endif

ASMOPT=-c -nologo -coff -Sg -Fl$* -Fo$* -D?FLAT=1 -I$(INC32DIR)
!if $(MASM)
ASM=@ml.exe $(ASMOPT) 
!else
ASM=@jwasm.exe $(ASMOPT) 
!endif

LIBS= ..\..\Lib\duser32s.lib

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).EXE

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).EXE: $*.obj Makefile
#	$(LINKBIN) @<<
#$*.obj 
#/SUBSYSTEM:CONSOLE
#/OPT:NOWIN98
#/FIXED:NO
#/STUB:..\..\Bin\LoadPE.bin
#/STACK:0x4000
#/OUT:$*.EXE
#/MAP:$*.MAP $(LIBS)
#<<
	jwlink @<<
format windows pe
ru console
file $*.obj
name $*.EXE
op stub=..\..\Bin\LoadPE.bin
op stack=0x4000
op map=$*.MAP
lib { $(LIBS) }
<<
	@..\..\Bin\PatchPe $*.exe

$(OUTDIR)\$(NAME).obj: $(NAME).asm Makefile
	@$(ASM) $(NAME).asm

clean:
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.exe
	@del $(OUTDIR)\*.map

