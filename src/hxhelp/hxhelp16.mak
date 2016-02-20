
# to create hxhelp16.exe enter: nmake
# adjust path for Open Watcom first (OWPATH=d:\watcom).
# ignore MS linker warning L4096 saying /BASE value being invalid for
# win95. This is no win32 app.

# switch MAKEMZ must remain 0. Currently there is no support for 
# hxhelp.exe in MZ file format.

# the HX.TRP file is generated in HX.TRP subdirectory
# it expects d:\WATCOM\TRP_SRC tree to exist!
# since that source is protected by copyrights, it is not included here!


!ifndef DEBUG
DEBUG=0
!endif

NAME=HXHELP16
OWPATH=D:\WATCOM
MAKEMZ=0
LOPT=/MAP:FULL /A:16

!if $(DEBUG)==0
OUTDIR=REL16
!else
OUTDIR=DEB16
!endif

!ifndef MASM
MASM=0
!endif

ASMOPT= -c -nologo -Sg -Fl$* -Fo$* -I..\..\Include -D?FLAT=0 -D?NE=1 -D?DEBUGLEVEL=$(DEBUG)
!if $(MASM)
ASM=@ml.exe $(ASMOPT) 
!else
ASM=@jwasm.exe $(ASMOPT)
!endif

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).EXE

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).EXE: $(OUTDIR)\hxhelp16.obj $(OUTDIR)\privprof.obj HXHELP16.mak hxhelp16.def
    link16 @<<
$*.obj $(OUTDIR)\privprof.obj $(LOPT),    
$*.EXE,
$*.MAP,
,
hxhelp16.DEF;
<<
	..\..\Bin\patchNE $*.EXE
    copy $*.EXE $(OWPATH)\binw\HXHP16.EXE
    copy $*.EXE ..\..\OWSUPP16\HXHP16.EXE

$(OUTDIR)\$(NAME).obj: hxhelp.asm hxhelp.inc version.inc rmdbghlp.inc HXHELP16.MAK
	$(ASM) hxhelp.asm

$(OUTDIR)\privprof.obj: privprof.asm HXHELP16.MAK
    $(ASM) privprof.asm
