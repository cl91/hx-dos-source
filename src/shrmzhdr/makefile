
# usage: nmake 

NAME=SHRMZHDR
NAME2=SETMZHDR
NAME3=ADDMZHDR

!include <..\dirs>

INCLUDE=..\..\Include

OUTDIR=Release

!ifndef MASM
MASM=0
!endif

!if $(MASM)
ASM=@ml.exe
!else
ASM=@jwasm.exe
!endif

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).EXE $(OUTDIR)\$(NAME2).EXE $(OUTDIR)\$(NAME3).EXE

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).EXE: $*.obj Makefile
	$(DMCDIR)\link.exe $* /NOLOGO/NON/MAP:FULL/ST:1024,$*.EXE,$*;
	copy $*.EXE ..\..\BIN\*.*

$(OUTDIR)\$(NAME).obj: $(NAME).asm Makefile
	$(ASM) -c -nologo -Sg -Fl$* -Fo$* -I..\..\Include $(NAME).asm

$(OUTDIR)\$(NAME2).EXE: $*.obj Makefile
	$(DMCDIR)\link.exe $* /NOLOGO/NON/MAP:FULL/ST:1024,$*.EXE,$*;
	copy $*.EXE ..\..\BIN\*.*

$(OUTDIR)\$(NAME2).obj: $(NAME2).asm Makefile
	$(ASM) -c -nologo -Sg -Fl$* -Fo$* -I..\..\Include $(NAME2).asm

$(OUTDIR)\$(NAME3).EXE: $*.obj Makefile
	$(DMCDIR)\link.exe $* /NOLOGO/NON/MAP:FULL/ST:1024,$*.EXE,$*;
	copy $*.EXE ..\..\BIN\*.*

$(OUTDIR)\$(NAME3).obj: $(NAME3).asm Makefile
	$(ASM) -c -nologo -Sg -Fl$* -Fo$* -I..\..\Include $(NAME3).asm

clean:
	@erase $(OUTDIR)\*.obj
	@erase $(OUTDIR)\*.lst
	@erase $(OUTDIR)\*.exe
