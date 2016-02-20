
# this will create SB16S.LIB, an OMF library for SB16.

# to create enter "nmake /f omf.mak"

# Please note: paths in file "..\dirs" have to be adjusted first!

# to create a debug version use "nmake /f omf.mak debug=1"
# the debug modules will be located in directory TEXTD,
# which probably has to be created first!

# tools:
# - JWasm
# - Wlib (Open Watcom)

# if MASM version >= 7.00 is used, option -omf has to be placed
# behind ml in ASM variable

!include <..\dirs>

!ifndef DEBUG
DEBUG=0
!endif

!if $(DEBUG)
AOPTD=-D_DEBUG
OUTDIR=OMFD
!else
AOPTD=
OUTDIR=OMF
!endif

NAME=SB16S

SRCMODS = \
!include modules.inc

OBJNAMES= $(SRCMODS:.ASM=.OBJ)
OBJMODS = $(OBJNAMES:.\=OMF\)

!ifndef MASM
MASM=0
!endif

ASMOPT= -c -nologo -Sg $(AOPTD) -D_SB16_=1 -I$(INC32DIR) -D?FLAT=1 -Fl$* -Fo$*
!if $(MASM)
ASM=@ml.exe $(ASMOPT)
!else
ASM=@jwasm.exe $(ASMOPT)
!endif

.SUFFIXES: .asm .obj

.asm{$(OUTDIR)}.obj:
    $(ASM) $<

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).LIB

$(OUTDIR):
	@mkdir $(OUTDIR)
    
$(OUTDIR)\$(NAME).LIB: $(OBJMODS) $(OUTDIR)\sb16.obj
	@cd $(OUTDIR)
    @if exist $(NAME).LIB del $(NAME).lib
    wlib.exe -q -n $(NAME).LIB @<<
$(OBJNAMES:.\=+)
<<
	@cd ..
!if $(DEBUG)==0
#	copy $*.LIB $(LIBOMF)\*.*
!endif    

$(OBJMODS): sb.inc dma.inc

clean:
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.lib
	@del $(OUTDIR)\*.lst
