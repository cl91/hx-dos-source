
# nmake makefile which creates DPMILD32.EXE/DPMILD32.BIN
# tools used:
# - Assembler: MASM
# - Linker:
#    + MS LINK 
#    + OPTLINK (Digital Mars)

!ifndef DEBUG
DEBUG = 0
!endif

!if $(DEBUG)
OUTDIR = DEBUG32
!else
OUTDIR = REL32
!endif

!include <..\dirs>

MSLINK=0

!ifndef MASM
MASM=0
!endif

NAME  = DPMILD32
LIBS  = 

AOPT = -c -nologo -Sg -Fl$* -Fo$* -D?32BIT=1 -D?DEBUG=$(DEBUG) -I..\..\Include

!if $(MASM)
ASM   = @ml.exe $(AOPT)
!else
ASM   = @jwasm.exe $(AOPT)
!endif

!if $(MSLINK)
LINK16  = @link16.exe
!else
LINK16  = @$(DMCDIR)\link.exe
!endif
LOPTS = /MAP:FULL/NOE/NON/ONERROR:NOEXE
DEPS  =   $(OUTDIR)\dpmildr.obj $(OUTDIR)\kernel16.obj $(OUTDIR)\peload.obj 
DEPSNOLFN = NOLFN32\dpmildr.obj   NOLFN32\kernel16.obj   NOLFN32\peload.obj 
#DEPSSTUB =   STUB32\dpmildr.obj    STUB32\kernel16.obj    STUB32\peload.obj 
DEPSSTUB =   STUB32\dpmildr.obj                           STUB32\peload.obj 
DEPSSTUBX =   STUBX32\dpmildr.obj 

!if $(DEBUG)
ALL: $(OUTDIR) $(OUTDIR)\$(NAME).EXE
!else
ALL: $(OUTDIR) NOLFN32 STUB32 STUBX32 $(OUTDIR)\$(NAME).EXE NOLFN32\$(NAME).EXE STUB32\$(NAME).BIN STUBX32\HDLD32.BIN
!endif

$(OUTDIR):
	@mkdir $(OUTDIR)

NOLFN32:
	@mkdir NOLFN32

STUB32:
	@mkdir STUB32

STUBX32:
	@mkdir STUBX32

# create $(OUTDIR)\DPMILD32.EXE

$(OUTDIR)\$(NAME).EXE: $(DEPS) $(NAME).mak
    $(LINK16) @<<
$(DEPS) $(LOPTS), $*.EXE, $*.MAP, $(LIBS);
<<
!if $(DEBUG)==0
    @copy $*.EXE ..\..\Bin\*.* >NUL
!ifdef TOOLSDIR
    @copy $*.EXE $(TOOLSDIR)\*.* >NUL
!endif
!endif    

$(OUTDIR)\dpmildr.OBJ: dpmildr.asm dpmildr.inc peload.inc kernel16.inc version.inc trace.inc
    $(ASM) dpmildr.asm

$(OUTDIR)\kernel16.OBJ: kernel16.asm dpmildr.inc peload.inc kernel16.inc version.inc trace.inc
    $(ASM) kernel16.asm

$(OUTDIR)\peload.OBJ: peload.asm dpmildr.inc peload.inc mzhdr32.inc
    $(ASM) peload.asm

# create NOLFN32\DPMILD32.EXE

NOLFN32\$(NAME).EXE: $(DEPSNOLFN) $(NAME).mak
    $(LINK16) @<<
$(DEPSNOLFN) $(LOPTS), $*.EXE, $*.MAP, $(LIBS);
<<
    @copy $*.EXE ..\..\Unsupp\*.* >NUL

NOLFN32\dpmildr.obj: dpmildr.asm dpmildr.inc peload.inc kernel16.inc version.inc trace.inc
    $(ASM) -D?LFN=0 dpmildr.asm

NOLFN32\kernel16.OBJ: kernel16.asm dpmildr.inc peload.inc kernel16.inc version.inc trace.inc
    $(ASM) -D?LFN=0 kernel16.asm

NOLFN32\peload.obj: peload.asm dpmildr.inc peload.inc mzhdr32.inc
    $(ASM) -D?LFN=0 peload.asm

# create STUB32\DPMILD32.BIN

STUB32\$(NAME).BIN: $(DEPSSTUB) $(NAME).mak
    @link16 /NOLOGO /KNOWEAS @<<
$(DEPSSTUB) $(LOPTS), $*.BIN, $*.MAP, $(LIBS);
<<
	..\..\Bin\SHRMZHDR $*.BIN
	@copy $*.BIN ..\..\Bin\*.* >NUL
!ifdef TOOLSDIR
	@copy $*.BIN $(TOOLSDIR)\*.* >NUL
!endif

STUB32\dpmildr.obj: dpmildr.asm dpmildr.inc peload.inc version.inc trace.inc dpmild32.mak
    $(ASM) -D?STUB=1 -D?KERNEL16=0 -D?LOADDBGDLL=0 dpmildr.asm

#STUB32\kernel16.OBJ: kernel16.asm dpmildr.inc peload.inc kernel16.inc version.inc trace.inc
#    $(ASM) -D?STUB=1 kernel16.asm

STUB32\peload.obj: peload.asm dpmildr.inc peload.inc mzhdr32.inc dpmild32.mak
    $(ASM) -D?STUB=1 -D?KERNEL16=0 peload.asm

# create STUBX32\HDLD32.BIN

STUBX32\HDLD32.BIN: $(DEPSSTUBX) $(NAME).mak
    @link16 /NOLOGO /KNOWEAS @<<
$(DEPSSTUBX) STUB32\peload.obj $(LOPTS), $*.BIN, $*.MAP, $(LIBS);
<<
	..\..\Bin\SHRMZHDR $*.BIN
#    ..\..\Bin\ADDMZHDR $*.BIN ..\HDPMI\STUB32\HDPMI32.BIN
	@copy $*.BIN ..\..\Bin\*.* >NUL
!ifdef TOOLSDIR
	@copy $*.BIN $(TOOLSDIR)\*.* >NUL
!endif

STUBX32\dpmildr.obj: dpmildr.asm dpmildr.inc peload.inc version.inc trace.inc ..\HDPMI\STUB32\HDPMI32.INC dpmild32.mak
    $(ASM) -D?STUB=1 -D?KERNEL16=0 -D?LOADDBGDLL=0 -D?SERVER=0 -D?HDPMI=1 -D?NEAPPS=0 dpmildr.asm

clean:
	@del $(OUTDIR)\*.exe
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.lib
	@del $(OUTDIR)\*.lst
	@del $(OUTDIR)\*.map
	@del NOLFN32\*.exe
	@del NOLFN32\*.obj
	@del NOLFN32\*.lib
	@del NOLFN32\*.lst
	@del NOLFN32\*.map
	@del STUB32\*.bin
	@del STUB32\*.obj
	@del STUB32\*.lib
	@del STUB32\*.lst
	@del STUB32\*.map
	@del STUBX32\*.bin
	@del STUBX32\*.obj
	@del STUBX32\*.lib
	@del STUBX32\*.lst
	@del STUBX32\*.map
