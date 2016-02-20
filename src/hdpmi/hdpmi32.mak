
# nmake makefile, creates HDPMI32.EXE.
# tools used:
#  - JWasm | Masm
#  - WLib (Open Watcom) | MS OMF LIB (lib16.exe)
#  - VALX (valx.exe, version >= 3.7.1.4)

# The current version of the HDPMI binary is a challenge for
# all linkers, because it requires full control over segment ordering.
# That's why most linkers fail now.


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
CP = 0
OBJMODS = $(OBJNAMES:.\=STD32D\)
!else
CP = 1
OBJMODS = $(OBJNAMES:.\=STD32\)
!endif

LIB16 = wlib.exe -q

!if $(DEBUG)
LINKER = 2
!else
LINKER = 1
!endif

# 1: VALX works, but make sure version is >= 3.7.1.4.
# 2: MS link works , but header size is 200h bytes, that's why SHRMZHDR
#    is called after the link step.
# 3: digital mars OPTLINK won't work. it has problems with segment ordering.
# 4: qlink won't work, some relocation targets are wrong
# 5: wlink won't work, does set SS=0 in MZ header

!if $(LINKER)==1
LINK  = valx.exe
LOPTS = /NCI /32 /MAP /DET:2
!elseif $(LINKER)==2
LINK  = link16.exe
LOPTS = /NOLOGO/MAP:FULL/NOI/NOE/NON/ONERROR:NOEXE $(LINKD)
!elseif $(LINKER)==3
LINK  = $(DMCDIR)\link.exe
LOPTS = /NOLOGO/FAR/MAP:FULL/NOREO/NOI/NOE/NON/ONERROR:NOEXE $(LINKD)
!elseif $(LINKER)==4
LINK  = c:\qlink\qlink.exe
LOPTS = /NOLOGO/FAR/MAP:FULL/NOI/NOE/NON/ONERROR:NOEXE $(LINKD)
!else
LINK  = wlink.exe
LOPTS = sys DOS
!endif

HSMODS=$(OUTHSEXT)\$(SRC).obj $(OUTHSEXT)\init.obj $(OUTHSEXT)\switch.obj $(OUTHSEXT)\i31swt.obj

!if $(LINKER)==5
LCMDS1=$(LOPTS) file $(OUTSTD)\$(SRC).obj name $*.EXE op map=$*.MAP lib $(OUTSTD)\$(NAME).lib
LCMDS2=$(LOPTS) file {$(OUTSTD)\$(SRC).obj $(OUTNOLFN)\INT21API.obj} name $*.EXE op map=$*.MAP lib $(OUTSTD)\$(NAME).lib
LCMDS3=$(LOPTS) file {$(HSMODS)} name $*.EXE op map=$*.MAP lib $(OUTSTD)\$(NAME).lib
LCMDS4=$(LOPTS) file {$(OUTSTUB)\$(SRC).obj $(OUTSTUB)\init.obj} name $*.BIN op map=$*.MAP lib $(OUTSTD)\$(NAME).lib
LCMDS5=$(LOPTS) file {$(OUTIOPL0)\$(SRC).obj $(OUTIOPL0)\switch.obj $(OUTIOPL0)\i31swt.obj} name $*.EXE op map=$*.MAP lib $(OUTSTD)\$(NAME).lib
!else
LCMDS1=$(LOPTS) $(OUTSTD)\$(SRC).obj, $*.EXE, $*.MAP, $(OUTSTD)\$(NAME).lib;
LCMDS2=$(LOPTS) $(OUTSTD)\$(SRC).obj $(OUTNOLFN)\INT21API.obj, $*.EXE, $*.MAP, $(OUTSTD)\$(NAME).lib;
LCMDS3=$(LOPTS) $(HSMODS), $*.EXE, $*.MAP, $(OUTSTD)\$(NAME).lib;
LCMDS4=$(LOPTS) $(OUTSTUB)\$(SRC).obj $(OUTSTUB)\init.obj, $*.BIN, $*.MAP, $(OUTSTD)\$(NAME).lib;
LCMDS5=$(LOPTS) $(OUTIOPL0)\$(SRC).obj $(OUTIOPL0)\switch.obj $(OUTIOPL0)\i31swt.obj, $*.EXE, $*.MAP, $(OUTSTD)\$(NAME).lib;
!endif


AFLAGS= -nologo -c -Cp -Sg -D?32BIT=1 $(ASMD) -I$(INC32DIR) -Fl$* -Fo$*

!if $(MASM)
AS    = @ml.exe
!else
AS    = @jwasm.exe
!endif

NAME  = HDPMI32
SRC   = hdpmi

DEPS0 = hdpmi.inc external.inc version.inc

!if $(DEBUG)
OUTSTD=STD32D
OUTNOLFN=NOLFN32D
OUTHSEXT=HSEXT32D
OUTSTUB=STUB32D
OUTIOPL0=IOPL032D
!else
OUTSTD=STD32
OUTNOLFN=NOLFN32
OUTHSEXT=HSEXT32
OUTSTUB=STUB32
OUTIOPL0=IOPL032
!endif

.SUFFIXES: .asm .obj

.asm{$(OUTSTD)}.obj:
    $(AS) $(AFLAGS) $<

# the following versions are created:
# 1. STD32:   standard version with LFN support
# 2. NOLFN32: non-LFN version
# 3. HSEXT32: version with host stack in extended memory [Hiword(ESP) != 0]
#             which requires very little DOS ram, but will not work with some
#             clients (DOS4G!)
# 4. STUB32:  stub version which will be used to create HDLD32.BIN
# 5. IOPL032: version which runs clients with IOPL=0 (Virtual PC)

TARGET1=$(OUTSTD)\$(NAME).EXE 
TARGET2=$(OUTNOLFN)\$(NAME).EXE 
TARGET3=$(OUTHSEXT)\$(NAME).EXE 
TARGET4=$(OUTSTUB)\$(NAME).INC 
TARGET5=$(OUTIOPL0)\$(NAME).EXE

ALL: $(OUTSTD) $(OUTNOLFN) $(OUTHSEXT) $(OUTSTUB) $(OUTIOPL0) $(TARGET1) $(TARGET2) $(TARGET3) $(TARGET4) $(TARGET5) 

$(OUTSTD):
	@mkdir $(OUTSTD)

$(OUTNOLFN):
	@mkdir $(OUTNOLFN)

$(OUTHSEXT):
	@mkdir $(OUTHSEXT)

$(OUTSTUB):
	@mkdir $(OUTSTUB)

$(OUTIOPL0):
	@mkdir $(OUTIOPL0)

$(OBJMODS): $(DEPS0)

# create the standard version

$(OUTSTD)\$(NAME).EXE: $(OUTSTD)\$(SRC).obj $(OUTSTD)\$(NAME).lib $(NAME).mak
    $(LINK) @<<
$(LCMDS1)
<<
!if $(CP)
!if $(LINKER)==2
    ..\..\BIN\SHRMZHDR.EXE -d $*.EXE
!endif
    ..\..\BIN\SETMZHDR.EXE $*.EXE
    copy $*.EXE ..\..\BIN\*.*
!ifdef TOOLSDIR
    copy $*.EXE $(TOOLSDIR)\*.*
!endif
!endif     

$(OUTSTD)\$(NAME).lib: $(OBJMODS) $(NAME).mak
	@cd $(OUTSTD)
	@erase $(NAME).lib
	$(LIB16) -n $(NAME).lib $(OBJNAMES:.\=+)
	$(LIB16) $(NAME).lib -$(SRC).OBJ
    @cd ..

# create the "no LFN" version

$(OUTNOLFN)\$(NAME).EXE: $(OUTSTD)\$(SRC).obj $(OUTNOLFN)\INT21API.obj $(OUTSTD)\$(NAME).lib $(NAME).mak
    $(LINK) @<<
$(LCMDS2)
<<
!if $(LINKER)==2
    ..\..\BIN\SHRMZHDR.EXE -d $*.EXE
!endif    
    ..\..\BIN\SETMZHDR.EXE $*.EXE

$(OUTNOLFN)\INT21API.obj: INT21API.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?LFNSUPPORT=0 INT21API.asm

# create the "host stack in extended memory" version

$(OUTHSEXT)\$(NAME).EXE: $(HSMODS) $(OUTSTD)\$(NAME).lib $(NAME).mak
    $(LINK) @<<
$(LCMDS3)
<<
!if $(LINKER)==2
    ..\..\BIN\SHRMZHDR.EXE -d $*.EXE
!endif    
    ..\..\BIN\SETMZHDR.EXE $*.EXE

$(OUTHSEXT)\$(SRC).obj: $(SRC).asm $(DEPS0)
     $(AS) $(AFLAGS) -D?HSINEXTMEM=1 $(SRC).asm

$(OUTHSEXT)\init.obj: init.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?HSINEXTMEM=1 init.asm

$(OUTHSEXT)\switch.obj: switch.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?HSINEXTMEM=1 switch.asm

$(OUTHSEXT)\i31swt.obj: i31swt.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?HSINEXTMEM=1 i31swt.asm

# create the stub version
# EXTRSECT: convert binary to asm include
# -i: create include
# -m: assume MZ binary

$(OUTSTUB)\$(NAME).INC: $*.BIN $(NAME).mak
    ..\..\TOOLS\EXTRSECT.EXE -m -i $*.BIN $*.INC

$(OUTSTUB)\$(NAME).BIN: $(OUTSTUB)\$(SRC).obj $(OUTSTUB)\init.obj $(OUTSTD)\$(NAME).lib $(NAME).mak
    $(LINK) @<<
$(LCMDS4)
<<

$(OUTSTUB)\$(SRC).obj: $(SRC).asm $(DEPS0)
     $(AS) $(AFLAGS) -D?STUB=1 $(SRC).asm

$(OUTSTUB)\init.obj: init.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?STUB=1 init.asm

# create the IOPL 0 version

$(OUTIOPL0)\$(NAME).EXE: $(OUTIOPL0)\$(SRC).obj $(OUTIOPL0)\switch.obj $(OUTIOPL0)\i31swt.obj $(OUTSTD)\$(NAME).lib $(NAME).mak
    $(LINK) @<<
$(LCMDS5)
<<
!if $(LINKER)==2
    ..\..\BIN\SHRMZHDR.EXE -d $*.EXE
!endif    
    ..\..\BIN\SETMZHDR.EXE $*.EXE

$(OUTIOPL0)\$(SRC).obj: $(SRC).asm $(DEPS0)
     $(AS) $(AFLAGS) -D?PMIOPL=00 $(SRC).asm

$(OUTIOPL0)\i31swt.obj: i31swt.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?PMIOPL=00 i31swt.asm

$(OUTIOPL0)\switch.obj: switch.asm $(DEPS0)
     $(AS) $(AFLAGS) -D?PMIOPL=00 switch.asm

clean:
    @del $(OUTSTD)\*.obj
    @del $(OUTSTD)\*.lib
    @del $(OUTSTD)\*.exe
    @del $(OUTSTD)\*.lst
    @del $(OUTSTD)\*.map
    @del $(OUTNOLFN)\*.obj
    @del $(OUTNOLFN)\*.exe
    @del $(OUTNOLFN)\*.lst
    @del $(OUTNOLFN)\*.map
    @del $(OUTHSEXT)\*.obj
    @del $(OUTHSEXT)\*.exe
    @del $(OUTHSEXT)\*.lst
    @del $(OUTHSEXT)\*.map
    @del $(OUTSTUB)\*.obj
    @del $(OUTSTUB)\*.bin
    @del $(OUTSTUB)\*.lst
    @del $(OUTSTUB)\*.map
    @del $(OUTSTUB)\*.inc
    @del $(OUTIOPL0)\*.obj
    @del $(OUTIOPL0)\*.exe
    @del $(OUTIOPL0)\*.lst
    @del $(OUTIOPL0)\*.map
