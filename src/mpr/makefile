
# this will create MPR.DLL
# adjust paths in file "..\dirs" first!
# to create a debug version use "nmake debug=1"
# output will be in subdir RELEASE or DEBUG, format
# of object modules is COFF format, true flat

!include <..\dirs>

!ifndef DEBUG
DEBUG=0
!endif

!if $(DEBUG)
AOPTD=-D_DEBUG
OUTDIR=DEBUG
!else
AOPTD=
OUTDIR=RELEASE
!endif

SRCMODS = \
!include modules.inc

OBJMODS = $(SRCMODS:.ASM=.OBJ)
!if $(DEBUG)
OBJMODS = $(OBJMODS:.\=DEBUG\)
!else
OBJMODS = $(OBJMODS:.\=RELEASE\)
!endif

!ifndef MASM
MASM=0
!endif

ASMOPT= -c -coff -nologo -Sg $(AOPTD) -I$(INC32DIR) -D?FLAT=1 -Fl$* -Fo$* 
!if $(MASM)
ASM=@ml.exe $(ASMOPT)
!else
ASM=@jwasm.exe $(ASMOPT)
!endif

LOPTS= /NOLOGO /MAP /SUBSYSTEM:CONSOLE /DLL /ENTRY:DllMain /FileAlign:0x200
LINK=link.exe

NAME=MPR
LIBNAME=MPRS
LIBS=$(LIBCOFF)\dkrnl32.lib

.SUFFIXES: .asm .obj

.asm{$(OUTDIR)}.obj:
    $(ASM) $<

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).dll

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).dll: $(OUTDIR)\$(LIBNAME).lib $(OUTDIR)\$(NAME).obj $(NAME).def
    $(LINK) @<<
$(OUTDIR)\$(NAME).obj $(OUTDIR)\$(LIBNAME).lib $(LIBS)
$(LOPTS) $(LOPTD)
/DEF:$(NAME).def /OUT:$*.DLL
<<
!if $(DEBUG)==0
     copy $*.DLL ..\..\bin\*.*
!ifdef DLL32DIR
     copy $*.DLL $(DLL32DIR)\*.*
!endif
#    copy $*.LIB $(LIBCOFF)\*.*
#   copy $(OUTDIR)\$(LIBNAME).LIB $(LIBCOFF)\*.*
!endif    

$(OUTDIR)\$(LIBNAME).lib: $(OBJMODS)
	@cd $(OUTDIR)
    lib.exe /NOLOGO @<<
$(SRCMODS:.ASM=.OBJ) /OUT:$(LIBNAME).lib
<<
	@cd ..

clean:
	@del $(OUTDIR)\*.dll
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.lib
	@del $(OUTDIR)\*.lst
