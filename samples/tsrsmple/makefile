
# this make file generates tsrsmple.exe in MZ file format
# source is in MASM format and the MS OMF linker is used (link16.exe)

NAME=tsrsmple
AS=ml -c -Fo$* -I..\..\Include
LIBS=..\..\libomf
MODS=$(LIBS)\dmythunk
OUTDIR=.

# Microsoft linker
LOPTS=/NOD/MAP/NOE/MAP:FULL/ONE:NOE
LINK=link16.exe

# Borland Linker
#LOPTS=/3 /m
#LINK=tlink

$(OUTDIR)\$(NAME).exe: $*.obj Makefile
    $(LINK) $(LOPTS) $(LIBS)\jmppm32 $* $(MODS),$*,$*,$(LIBS)\jmppm32 $(LIBS)\duser32s;

$(OUTDIR)\$(NAME).obj: $(NAME).asm
    $(AS) $(NAME).asm

