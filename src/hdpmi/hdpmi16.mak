
# nmake makefile, creates HDPMI16.EXE.
# tools:
# - JWasm | Masm
# - WLib (Open Watcom) | MS OMF lib (lib16.exe)
# - VALX linker!

!include <..\dirs>

!ifndef DEBUG
DEBUG = 0
!endif

!ifndef MASM
MASM=0
!endif

!if $(DEBUG)
ASMD=-Zi -D_DEBUG
LINKD=/LI
!endif

SRCMODS = \
!include modules.inc
OBJNAMES = $(SRCMODS:.ASM=.OBJ)
!if $(DEBUG)
OBJMODS = $(OBJNAMES:.\=STD16D\)
!else
OBJMODS = $(OBJNAMES:.\=STD16\)
!endif

LIBC = wlib.exe -q

# currently VALX is used, but make sure version is >= 3.7.1.4.
# MS link also works, but then it is recommended to activate the line
# containing SHRMZHDR.EXE to reduce size of binary.
# digital mars linker has problems with segment ordering

!if $(DEBUG)
LINKER = 2
!else
LINKER = 1
!endif

!if $(LINKER)==1
LINK  = valx.exe
LOPTS = /NCI /32 /MAP /DET:2
!elseif $(LINKER)==2
LINK  = link16.exe
LOPTS = /NOLOGO/FAR/MAP:FULL/NOE/NOI/NON/ONERROR:NOEXE $(LINKD)
!elseif $(LINKER)==3
LINK  = $(DMCDIR)\link.exe
LOPTS = /NOLOGO/FAR/MAP:FULL/NOREO/NOI/NOE/NON/ONERROR:NOEXE $(LINKD)
!elseif $(LINKER)==4
LINK  = c:\qlink\qlink.exe
LOPTS = /NOLOGO/FAR/MAP:FULL/NOI/NOE/NON/ONERROR:NOEXE $(LINKD)
!else
LINK  = tlink.exe
LOPTS = /3 /Td /s /c
!endif

AFLAGS= -nologo -c -Cp -Sg -D?32BIT=0 $(ASMD) -I$(INC32DIR) -Fl$* -Fo$*

!if $(MASM)
AS    = @ml.exe
!else
AS    = @jwasm.exe
!endif

NAME  = HDPMI16
SRC   = hdpmi

DEPS0 = hdpmi.inc external.inc version.inc

!if $(DEBUG)
OUTSTD=STD16D
OUTNOLFN=NOLFN16D
OUTENH=ENH16D
OUTSTUB=STUB16D
OUTIOPL0=IOPL016D
!else
OUTSTD=STD16
OUTNOLFN=NOLFN16
OUTENH=ENH16
OUTSTUB=STUB16
OUTIOPL0=IOPL016
!endif

.SUFFIXES: .asm .obj

.asm{$(OUTSTD)}.obj:
    $(AS) $(AFLAGS) $<

ALL: $(OUTSTD) $(OUTNOLFN) $(OUTENH) $(OUTSTUB) $(OUTIOPL0) $(OUTSTD)\$(NAME).EXE $(OUTNOLFN)\$(NAME).EXE $(OUTENH)\$(NAME).EXE $(OUTSTUB)\$(NAME).INC $(OUTIOPL0)\$(NAME).EXE

$(OBJMODS): $(DEPS0)

$(OUTSTD):
	@mkdir $(OUTSTD)

$(OUTNOLFN):
	@mkdir $(OUTNOLFN)

$(OUTENH):
	@mkdir $(OUTENH)

$(OUTSTUB):
	@mkdir $(OUTSTUB)

$(OUTIOPL0):
	@mkdir $(OUTIOPL0)

# create the standard version

$(OUTSTD)\$(NAME).EXE: $(OUTSTD)\$(SRC).obj $(OUTSTD)\$(NAME).lib $(NAME).mak $(OUTNOLFN)\int21api.obj 
    $(LINK) @<<
$(OUTSTD)\$(SRC).obj $(LOPTS), $*.EXE, $*.map, $(OUTSTD)\$(NAME).lib;
<<
!if $(DEBUG)==0
!if $(LINKER)==2
     ..\..\BIN\SHRMZHDR.EXE $*.exe
!endif     
     ..\..\BIN\SETMZHDR.EXE $*.EXE
     @copy $*.EXE ..\..\Bin\*.*
!ifdef TOOLSDIR     
     @copy $*.EXE $(TOOLSDIR)\$(NAME).EXE
!endif     
!endif

$(OUTSTD)\$(NAME).lib: $(OBJMODS) $(NAME).mak
	@cd $(OUTSTD)
    @erase $(NAME).lib
	$(LIBC) -n $(NAME).lib $(OBJNAMES:.\=+)
    @cd ..

# create the "no LFN" version

$(OUTNOLFN)\$(NAME).EXE: $(OUTSTD)\$(SRC).obj $(OUTNOLFN)\INT21API.obj $(OUTSTD)\$(NAME).lib $(NAME).mak
    $(LINK) @<<
$(LOPTS) $(OUTSTD)\$(SRC).obj $(OUTNOLFN)\INT21API.obj, $*.EXE, $*.MAP, $(OUTSTD)\$(NAME).lib;
<<
!if $(LINKER)==2 || $(LINKER)==5
    ..\..\BIN\SHRMZHDR.EXE -d $*.EXE
!endif    
    ..\..\BIN\SETMZHDR.EXE $*.EXE

$(OUTNOLFN)\INT21API.obj: INT21API.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?LFNSUPPORT=0 INT21API.asm
     
# create the "windows enhanced mode" version

$(OUTENH)\$(NAME).exe: $(OUTENH)\hdpmi.obj $(OUTENH)\int2fapi.obj $(OUTENH)\int31api.obj $(OUTENH)\vxd.obj $(OUTSTD)\$(NAME).lib $(NAME).mak
    $(LINK) @<<
$(OUTENH)\hdpmi.obj $(OUTENH)\INT2FAPI.obj $(OUTENH)\INT31API.obj $(OUTENH)\vxd.obj $(LOPTS), $*.EXE, $*.MAP, $(OUTSTD)\$(NAME).lib;
<<
!if $(DEBUG)==0    
!if $(LINKER)==2
     ..\..\BIN\SHRMZHDR.EXE $*.EXE
!endif
     ..\..\BIN\SETMZHDR.EXE $*.EXE
#     copy $*.EXE ..\..\Unsupp
!endif     

$(OUTENH)\hdpmi.obj: hdpmi.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?ENHANCED=1 hdpmi.asm

$(OUTENH)\INT2FAPI.obj: INT2FAPI.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?ENHANCED=1 INT2FAPI.asm

$(OUTENH)\INT31API.obj: INT31API.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?ENHANCED=1 INT31API.asm

$(OUTENH)\vxd.obj: vxd.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?ENHANCED=1 vxd.asm

# create the stub version
# EXTRSECT: convert binary to asm include
# -i: create include
# -m: assume MZ binary

$(OUTSTUB)\$(NAME).INC: $*.BIN $(NAME).mak
    ..\..\TOOLS\EXTRSECT.EXE -m -i $*.BIN $*.INC

$(OUTSTUB)\$(NAME).BIN: $(OUTSTUB)\$(SRC).obj $(OUTSTUB)\init.obj $(OUTSTD)\$(NAME).lib $(NAME).mak
    $(LINK) @<<
$(LOPTS) $(OUTSTUB)\$(SRC).obj $(OUTSTUB)\init.obj, $*.BIN, $*.MAP, $(OUTSTD)\$(NAME).lib;
<<

$(OUTSTUB)\$(SRC).obj: $(SRC).asm $(DEPS0)
     $(AS) $(AFLAGS) -D?STUB=1 $(SRC).asm

$(OUTSTUB)\init.obj: init.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?STUB=1 init.asm

# create the "IOPL0" version

$(OUTIOPL0)\$(NAME).EXE: $(OUTIOPL0)\$(SRC).obj $(OUTIOPL0)\switch.obj $(OUTIOPL0)\i31swt.obj $(OUTSTD)\$(NAME).lib $(NAME).mak
    $(LINK) @<<
$(LOPTS) $(OUTIOPL0)\$(SRC).obj $(OUTIOPL0)\switch.obj $(OUTIOPL0)\i31swt.obj, $*.EXE, $*.MAP, $(OUTSTD)\$(NAME).lib;
<<
!if $(LINKER)==2 || $(LINKER)==5
    ..\..\BIN\SHRMZHDR.EXE -d $*.EXE
!endif    
    ..\..\BIN\SETMZHDR.EXE $*.EXE


$(OUTIOPL0)\$(SRC).obj: $(SRC).asm $(DEPS0)
     $(AS) $(AFLAGS) -D?PMIOPL=00 $(SRC).asm

$(OUTIOPL0)\switch.obj: switch.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?PMIOPL=00 switch.asm

$(OUTIOPL0)\i31swt.obj: i31swt.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?PMIOPL=00 i31swt.asm

clean:
    @del $(OUTSTD)\*.obj
    @del $(OUTSTD)\*.lib
    @del $(OUTSTD)\*.exe
    @del $(OUTSTD)\*.map
    @del $(OUTSTD)\*.lst
    @del $(OUTNOLFN)\*.exe
    @del $(OUTNOLFN)\*.obj
    @del $(OUTNOLFN)\*.lst
    @del $(OUTNOLFN)\*.map
    @del $(OUTENH)\*.obj
    @del $(OUTENH)\*.exe
    @del $(OUTENH)\*.map
    @del $(OUTENH)\*.lst
    @del $(OUTIOPL0)\*.obj
    @del $(OUTIOPL0)\*.exe
    @del $(OUTIOPL0)\*.lst
    @del $(OUTIOPL0)\*.map

