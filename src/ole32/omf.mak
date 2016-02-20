
# this will create OLE32S.LIB, an OMF library for Win32 emulation

# to create enter "nmake /f omf.mak"

# Please note: paths in file "..\dirs" have to be adjusted first!

# to create a debug version use "nmake /f omf.mak debug=1"
# the debug modules will be located in directory OMFD,
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

NAME=OLE32S

SRCMODS = \
!include modules.inc

OBJNAMES= $(SRCMODS:.ASM=.OBJ)
OBJMODS = $(OBJNAMES:.\=OMF\)

!ifndef MASM
MASM=0
!endif

ASMOPT= -c -nologo -Cp -Sg $(AOPTD) -I$(INC32DIR) -D?FLAT=1 -Fl$* -Fo$*
!if $(MASM)
ASM=@ml.exe $(ASMOPT)
!else
ASM=@jwasm.exe $(ASMOPT)
!endif

.SUFFIXES: .asm .obj

.asm{$(OUTDIR)}.obj:
    $(ASM) $<

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).lib

$(OUTDIR):
	@mkdir $(OUTDIR)
    
$(OUTDIR)\$(NAME).lib: $(OBJMODS)
	@cd $(OUTDIR)
    @if exist $(NAME).lib del $(NAME).lib
    wlib.exe -q -n $(NAME).lib @<<
$(OBJNAMES:.\=+)
<<
	@cd ..
!if $(DEBUG)==0
#	copy $*.lib $(LIBOMF)\*.*
!endif    
