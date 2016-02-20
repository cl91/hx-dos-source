
# nmake makefile which creates DPMILD16.EXE/DPMILD16.BIN
# tools used:
# - Assembler: MASM
# - Linker:
#    + MS LINK 
#    + OPTLINK (Digital Mars)

!ifndef DEBUG
DEBUG = 0
!endif

!if $(DEBUG)
OUTDIR = DEBUG16
!else
OUTDIR = REL16
!endif

!include <..\dirs>

NAME  = DPMILD16
LOPTS = /FAR/MAP:FULL/NOE/NON/ONERROR:NOEXE/NOD
#LINK16  = link16.exe
LINK16  = $(DMCDIR)\link.exe
LIBS  = LIB16\ldr16.lib

!ifndef MASM
MASM=0
!endif

AOPT = -c -Sg -Fl$* -Fo$* -nologo -D?32BIT=0 -D?DEBUG=$(DEBUG) -I..\..\Include

!if $(MASM)
ASM   = @ml.exe $(AOPT)
!else
ASM   = @jwasm.exe $(AOPT)
!endif

!if $(DEBUG)
ALL: $(OUTDIR)\$(NAME).EXE
!else
ALL: $(OUTDIR) STUB16 STUBX16 $(OUTDIR)\$(NAME).EXE STUB16\$(NAME).BIN STUBX16\HDLD16.BIN
!endif

$(OUTDIR):
	@mkdir $(OUTDIR)

STUB16:
	@mkdir STUB16

STUBX16:
	@mkdir STUBX16

# create $(OUTDIR)\DPMILD16.EXE

$(OUTDIR)\$(NAME).EXE: $(OUTDIR)\dpmildr.obj $(OUTDIR)\kernel16.obj LIB16\ldr16.lib $(NAME).mak 
	@$(LINK16) @<<
$(OUTDIR)\dpmildr.obj $(OUTDIR)\kernel16.obj $(LOPTS), $*.EXE, $*.map, $(LIBS);
<<
!if $(DEBUG)==0
	@copy $*.EXE ..\..\bin >NUL
!ifdef TOOLSDIR    
	@copy $*.EXE $(TOOLSDIR)\$(NAME).EXE
!endif    
!endif

$(OUTDIR)\dpmildr.obj: dpmildr.asm dpmildr.inc kernel16.inc version.inc trace.inc
	$(ASM) dpmildr.asm

$(OUTDIR)\kernel16.obj: kernel16.asm dpmildr.inc kernel16.inc version.inc trace.inc
	$(ASM) kernel16.asm

# create STUB16\DPMILD16.BIN

STUB16\$(NAME).BIN: STUB16\dpmildr.OBJ STUB16\kernel16.obj LIB16\ldr16.lib $(NAME).mak 
	@link16 /NOLOGO /KNOWEAS @<<
STUB16\dpmildr.obj STUB16\kernel16.obj $(LOPTS), $*.BIN, $*.map, $(LIBS);
<<
	@..\..\Bin\SHRMZHDR $*.BIN
	@copy $*.BIN ..\..\Bin\*.* >NUL
!ifdef TOOLSDIR
	@copy $*.BIN $(TOOLSDIR)\*.* >NUL
!endif

STUB16\dpmildr.obj: dpmildr.asm dpmildr.inc kernel16.inc version.inc trace.inc
    $(ASM) -D?STUB=1 dpmildr.asm

STUB16\kernel16.obj: kernel16.asm dpmildr.inc kernel16.inc version.inc trace.inc
    $(ASM) -D?STUB=1 kernel16.asm

# create STUBX16\HDLD16.BIN

STUBX16\HDLD16.BIN: STUBX16\dpmildr.OBJ $(OUTDIR)\kernel16.OBJ LIB16\ldr16.lib $(NAME).mak
    @link16 /NOLOGO /KNOWEAS @<<
STUBX16\dpmildr.OBJ $(OUTDIR)\kernel16.OBJ $(LOPTS), $*.BIN, $*.MAP, $(LIBS);
<<
	..\..\Bin\SHRMZHDR $*.BIN
	@copy $*.BIN ..\..\Bin\*.* >NUL
!ifdef TOOLSDIR
	@copy $*.BIN $(TOOLSDIR)\*.* >NUL
!endif

STUBX16\dpmildr.obj: dpmildr.asm dpmildr.inc peload.inc version.inc trace.inc ..\HDPMI\STUB16\HDPMI16.INC dpmild16.mak
    $(ASM) -D?STUB=1 -D?LOADDBGDLL=0 -D?SERVER=0 -D?HDPMI=1 dpmildr.asm

clean:
	@del $(OUTDIR)\*.exe
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.lib
	@del $(OUTDIR)\*.lst
	@del $(OUTDIR)\*.map
	@del STUB16\*.exe
	@del STUB16\*.obj
	@del STUB16\*.lib
	@del STUB16\*.lst
	@del STUB16\*.map
