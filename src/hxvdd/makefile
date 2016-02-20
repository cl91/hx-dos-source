
# NMAKE makefile, creates HXVDD.DLL
# tools used:
# - JWasm or Masm v6
# - POLINK or MS link

NAME=HXVDD

!ifndef DEBUG
DEBUG=0
!endif

!if $(DEBUG)
OUTDIR=DEBUG
AOPTD=-Sg -D_DEBUG
!else
OUTDIR=RELEASE
AOPTD=
!endif

ASM=@jwasm.exe -c -nologo -Fl$* -Fo$* -coff $(AOPTD) -I ..\..\Include
LINK=@link.exe
LOPTSD=/NOLOGO /MAP /SUBSYSTEM:CONSOLE /DLL /LIBPATH:..\..\Lib /MERGE:.rdata=.text /BASE:0x73E00000 /OPT:NOWIN98
LIBS=dkrnl32.lib duser32.lib ntvdm.lib

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).DLL

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).DLL: $*.obj $(NAME).def Makefile
	$(LINK) $*.OBJ /OUT:$*.DLL $(LOPTSD) $(LIBS) /DEF:$(NAME).def
	copy $*.dll ..\..\Bin\*.*

$(OUTDIR)\$(NAME).OBJ: $(NAME).asm Makefile
    $(ASM) $(NAME).asm

