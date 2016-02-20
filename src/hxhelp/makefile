
# to create hxhelp.exe enter: nmake
# adjust path for Open Watcom first (OWPATH=d:\watcom).
# ignore MS linker warning L4096 saying /BASE value being invalid for
# win95. This is no win32 app.

# switch MAKEMZ must remain 0. Currently there is no support for 
# hxhelp.exe in MZ file format.

# the HX.TRP file is generated in HX.TRP subdirectory
# it expects \WATCOM\TRP_SRC tree to exist!
# since that source is protected by copyrights, it is not included here!

!include <..\dirs>

!ifndef DEBUG
DEBUG=0
!endif

NAME=HXHELP
OWPATH=$(OWDIR)
MAKEMZ=0

!if $(MAKEMZ)==0

!if $(DEBUG)==0
OUTDIR=RELEASE
!else
OUTDIR=DEBUG
!endif

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).EXE

ASMOPT=-c -coff -nologo -D?FLAT=1 -D?DEBUGLEVEL=$(DEBUG) -Sg -Fl$* -Fo$* -I..\..\Include 
!ifndef MASM
MASM=0
!endif

!if $(MASM)
ASM=@ml.exe
!else
ASM=@jwasm.exe
!endif

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).EXE: $(OUTDIR)\hxhelp.obj Makefile $(OUTDIR)\privprof.obj
#	$(LINKBIN) @<<
#$*.obj $(OUTDIR)\privprof.obj
#/base:0x3E0000
#/fixed:no
#/heap:0x0
#/map
#/out:$*.EXE 
#/subsystem:console
#/stack:0x2000
#/stub:..\..\bin\dpmist32.bin
#<<
	@jwlink @<<
format windows nt
runtime console
file $*.obj, $(OUTDIR)\privprof.obj
name $*.EXE
op q
op offset=0x3E0000
op stack=0x2000
op heap=0x1000
op map=$*.MAP
op stub=..\..\bin\dpmist32.bin
<<
	@..\..\Bin\patchPE $*.EXE
	@copy $*.EXE $(OWPATH)\binw >NUL
	@copy $*.EXE ..\..\OWSUPP\WDSUPP >NUL
!else    

OUTDIR=OMF
ASMOPT=

$(OUTDIR)\$(NAME).EXE: $(OUTDIR)\hxhelp.obj Makefile $(OUTDIR)\privprof.obj
	@$(LINK16BIN) /MAP ..\..\lib\jmppm32.obj $*.obj $(OUTDIR)\privprof.obj,$*.exe,$*.map,..\..\lib\jmppm32.lib; 
	@copy $*.exe $(OWPATH)\binw
!endif

$(OUTDIR)\$(NAME).obj: $(NAME).asm hxhelp.inc rmdbghlp.inc version.inc Makefile
	$(ASM) $(ASMOPT) $(NAME).asm

$(OUTDIR)\privprof.obj: privprof.asm Makefile
	$(ASM) $(ASMOPT) privprof.asm

clean:
    @del $(OUTDIR)\*.obj
    @del $(OUTDIR)\*.map
    @del $(OUTDIR)\*.lst
    @del $(OUTDIR)\*.exe
