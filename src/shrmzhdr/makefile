
# nmake makefile to create SHRMZHDR.EXE, SETMZHDR.EXE, ADDMZHDR
# slightly obsolete by now
# uses: JWasm

NAME=SHRMZHDR
NAME2=SETMZHDR
NAME3=ADDMZHDR

!include <..\dirs>

INCLUDE=..\..\Include

OUTDIR=Release

ASM=@jwasm.exe

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).EXE $(OUTDIR)\$(NAME2).EXE $(OUTDIR)\$(NAME3).EXE

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).EXE: $(NAME).asm Makefile
	$(ASM) -c -nologo -mz -Sg -Fl$* -Fo$*.EXE -I..\..\Include $(NAME).asm
	copy $*.EXE ..\..\BIN\*.*

$(OUTDIR)\$(NAME2).EXE: $(NAME2).asm Makefile
	$(ASM) -c -nologo -mz -Sg -Fl$* -Fo$*.EXE -I..\..\Include $(NAME2).asm
	copy $*.EXE ..\..\BIN\*.*

$(OUTDIR)\$(NAME3).EXE: $(NAME3).asm Makefile
	$(ASM) -c -nologo -mz -Sg -Fl$* -Fo$*.EXE -I..\..\Include $(NAME3).asm
	copy $*.EXE ..\..\BIN\*.*

clean:
	@erase $(OUTDIR)\*.lst
	@erase $(OUTDIR)\*.exe
