
#--- before running nmake create subdirectory Release first!

name = PESTUB

#--- this app may be generated as standard MZ executable as well
#--- but then set the path of the 16-bit OMF linker first
#--- currently used: Digital Mars C++ OMF linker

MZAPP=0
USEDLL=0

!ifndef MASM
MASM=0
!endif

!ifndef DEBUG
DEBUG=0
!endif

!if $(MZAPP)
OUTDIR=OMF
AOPTD=
!elseif $(DEBUG)
OUTDIR=DEBUG
AOPTD=-Zi -D_DEBUG
!else
OUTDIR=RELEASE
AOPTD=
!endif

!include <..\dirs>

!if $(MZAPP)

LOPTD=

ASMOPT= -c -nologo -Sg -Fl$* -Fo$* -D?FLAT=0 -D_ML $(AOPTD) -I$(INC32DIR)

!if $(MASM)
ASM = @ml.exe $(ASMOPT)
!else
ASM = @jwasm.exe $(ASMOPT)
!endif

!if 0
LIBS=$(LIBOMF)\jmppm32.lib $(LIBOMF)\dkrnl32s.lib $(LIBOMF)\duser32s.lib $(LIBOMF)\libc32.lib
LOPT=/MAP:FULL/NON/NOE/NOD/ONE:NOE/NOLOGO $(LOPTD)
LINK=link16.exe
MODS=$(LIBOMF)\jmppm32.obj $*.obj $(LIBOMF)\dmythunk.obj
!else
LIBS=$(LIBOMF)\jmppm32.lib $(LIBOMF)\dkrnl32s.lib $(LIBOMF)\libc32.lib
LOPT=/MAP:FULL/NON/NOE
LINK=$(DMCDIR)\link.exe
MODS=$*.obj $(LIBOMF)\jmppm32.obj $(LIBOMF)\dmythunk.obj
!endif

!else

!if $(DEBUG)
LOPTD=/DEBUG
!else
LOPTD=
!endif

ASMOPT2= -c -coff -nologo -Sg -Fl$* -Fo$* -D?FLAT=1 $(AOPTD) -I$(INC32DIR)
!if $(MASM)
ASM = @ml.exe $(ASMOPT2)
!else
ASM = @jwasm.exe $(ASMOPT2)
!endif

!if $(USEDLL)
CRTLIB=$(LIBCOFF)\crtdll.lib
!else
CRTLIB=$(LIBCOFF)\libc32s.lib
!endif
LIBS= $(LIBCOFF)\dkrnl32.lib $(LIBCOFF)\duser32s.lib $(CRTLIB)
LOPT=/OUT:$*.EXE /NOLOGO /NODEFAULTLIB /MAP:$*.map /SUBSYSTEM:CONSOLE $(LOPTD) /FIXED:NO  /STUB:..\..\bin\dpmist32.bin /MERGE:.rdata=.data /MERGE:.reloc=.text /OPT:NOWIN98
LINK=polink

!endif

ALL: $(OUTDIR) $(OUTDIR)\$(name).EXE

$(OUTDIR):
	@mkdir $(OUTDIR)

!if $(MZAPP)
$(OUTDIR)\$(name).EXE: $*.obj makefile
    $(LINK) @<<
$(MODS),$*,$*,$(LIBS) $(LOPT);
<<
!else
$(OUTDIR)\$(name).EXE: $*.obj makefile
    $(LINK) $* $(LIBS) $(LOPT)
!if $(DEBUG)==0
	@copy $*.EXE ..\..\bin\*.* >NUL
!ifdef TOOLSDIR
	@copy $*.EXE $(TOOLSDIR)\$(name).EXE
!endif    
!endif
!endif

$(OUTDIR)\$(name).obj: $(name).asm makefile
     $(ASM) $(name).asm

clean:
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.exe
	@del $(OUTDIR)\*.lst
	@del $(OUTDIR)\*.map

