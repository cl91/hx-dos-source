
# creates SHDPMI.EXE (DOS-PE) and SHDPMIR.EXE (DOS 16bit TSR)

NAME=SHDPMI

!include <..\dirs>

!ifndef DEBUG
DEBUG=0
!endif

!if $(DEBUG)
OUTDIR=DEBUG
!else
OUTDIR=RELEASE
!endif

!ifndef MASM
MASM=0
!endif

ASMOPT1= -c -coff -nologo -Sg -Fl$* -Fo$* -D?FLAT=1 -D_KERNEL32_ -D_USER32_ -I$(INC32DIR)
ASMOPT2= -c -nologo -Sg -Fl$* -Fo$* 

!if $(MASM)
AS=@ml.exe $(ASMOPT1)
ASR=@ml.exe $(ASMOPT2)
!else
AS=@jwasm.exe $(ASMOPT1)
ASR=@jwasm.exe $(ASMOPT2)
!endif

LINK=@link.exe /nologo
LIBS=$(LIBCOFF)\duser32s.lib
LOPTS= /MAP:$*.MAP /FIXED:NO /OPT:NOWIN98 /STUB:..\..\Bin\LOADPE.BIN 

#LOPTSR= /MAP/ONE:NOE/NOD
#LINKR=@link16.exe $(LOPTSR) $*.obj,$*.EXE,$*.MAP;
LOPTSR=sys DOS
LINKR=@$(OWDIR)\BINW\wlink.exe op q $(LOPTSR) file $*.obj name $*.EXE op map=$*.MAP


ALL: $(OUTDIR) $(OUTDIR)\$(NAME).EXE $(OUTDIR)\$(NAME)R.EXE

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).EXE: $*.obj Makefile
    $(LINK) @<<
/SUBSYSTEM:CONSOLE $*.obj $(LOPTS) /OUT:$*.EXE /MAP:$*.MAP $(LIBS)
<<
	@..\..\Bin\PatchPE $*.EXE
!if $(DEBUG)==0
	@copy $*.EXE ..\..\Bin\*.* >NUL
!endif    

$(OUTDIR)\$(NAME).obj: $(NAME).asm Makefile
    $(AS) $(NAME).asm

#--- this is a DOS TSR

$(OUTDIR)\$(NAME)R.EXE: $*.obj Makefile
    $(LINKR)
!if $(DEBUG)==0
	@copy $*.EXE ..\..\Bin\*.* >NUL
!endif    

$(OUTDIR)\$(NAME)R.obj: $(NAME)R.asm Makefile
	$(ASR) $(NAME)R.asm

clean:
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.exe
	@del $(OUTDIR)\*.lst
	@del $(OUTDIR)\*.map
