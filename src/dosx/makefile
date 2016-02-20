

!include <..\dirs>

OUTDIR=RELEASE

LIB=$(LIBOMF)
AOPTS= -c -nologo -Fo$* -Fl$* -Sg

!ifndef MASM
MASM=0
!endif

!if $(MASM)
ASM=@ml.exe $(AOPTS)
!else
ASM=@jwasm.exe $(AOPTS)
!endif

LOPTS=$(XLOPTS)/ONE:NOE/NOE/MAP:FULL/NON/FAR/STACK:2048

ALL: $(OUTDIR) $(OUTDIR)\dosx.exe

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\DOSX.EXE: $*.obj makefile
#   @link16 $* $(MODS) $(LOPTS),$*,$*,$(LIBS);
	@\dm\bin\link $* $(MODS) $(LOPTS),$*,$*,$(LIBS);
	@copy $*.EXE ..\..\Unsupp\*.*
	@copy DOSX.TXT ..\..\Unsupp\*.*

$(OUTDIR)\dosx.obj: dosx.asm makefile
	$(ASM) dosx.asm

