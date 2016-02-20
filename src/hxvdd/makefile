
# NMAKE makefile, creates HXVDD.DLL
# tools used:
# - JWasm or Masm v6
# - JWlink or MS link

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

MSLINK=0
LOPTSD=/NOLOGO /MAP /SUBSYSTEM:CONSOLE /DLL /LIBPATH:..\..\Lib /MERGE:.rdata=.text /BASE:0x73E00000 /OPT:NOWIN98
LIBS=dkrnl32.lib duser32.lib ntvdm.lib

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).DLL

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).DLL: $*.obj $(NAME).def Makefile
!if $(MSLINK)
	@link $*.OBJ /OUT:$*.DLL $(LOPTSD) $(LIBS) /DEF:$(NAME).def
!else
	@jwlink format win pe dll name $*.DLL f $*.OBJ libpath ..\..\Lib lib { $(LIBS) } op q, map=$*, implib=$*, offset=0x73E00000 @$(NAME).rsp
!endif
	copy $*.dll ..\..\Bin\*.*

$(OUTDIR)\$(NAME).OBJ: $(NAME).asm Makefile
	$(ASM) $(NAME).asm

clean:
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.dll
	@del $(OUTDIR)\*.map
	@del $(OUTDIR)\*.lst


