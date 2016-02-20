
# this will create COMCTL32.DLL
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

ASMOPT= -c -nologo -Sg $(AOPTD) -I$(INC32DIR)
!if $(MASM)
ASM=@ml.exe -coff $(ASMOPT) -D?FLAT=1 -Fl$* -Fo$* 
!else
ASM=@jwasm.exe -coff $(ASMOPT) -D?FLAT=1 -Fl$* -Fo$* 
!endif

LOPTS= /NOLOGO /MAP /SUBSYSTEM:CONSOLE /DLL /ENTRY:DllMain /LIBPATH:$(LIBCOFF)

NAME=COMCTL32
LIBNAME=COMCTLS
LIBS=dkrnl32.lib duser32.lib

.SUFFIXES: .asm .obj

.asm{$(OUTDIR)}.obj:
    $(ASM) $<

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).dll

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).dll: $(OUTDIR)\$(LIBNAME).lib $(OUTDIR)\$(NAME).obj $(NAME).def
    $(LINKBIN) @<<
$(OUTDIR)\$(NAME).obj $(OUTDIR)\$(LIBNAME).lib $(LIBS)
$(LOPTS) $(LOPTD)
/DEF:$(NAME).def /OUT:$*.DLL
<<
!if $(DEBUG)==0
     copy $*.DLL ..\..\bin\*.* >NUL
!ifdef DLL32DIR
     copy $*.DLL $(DLL32DIR)\*.*
!endif
#    copy $*.LIB $(LIBCOFF)\*.*
#   copy $(OUTDIR)\$(LIBNAME).LIB $(LIBCOFF)\*.*
!endif    

$(OUTDIR)\$(LIBNAME).lib: $(OBJMODS)
	@cd $(OUTDIR)
    $(LIBBIN) /NOLOGO @<<
$(SRCMODS:.ASM=.OBJ) /OUT:$(LIBNAME).lib
<<
	@cd ..

clean:
    @del $(OUTDIR)\*.obj
    @del $(OUTDIR)\*.dll
    @del $(OUTDIR)\*.lib
    @del $(OUTDIR)\*.map
    @del $(OUTDIR)\*.lst
    @del $(OUTDIR)\*.exp
