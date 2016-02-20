
# Makefile for NMAKE. creates HXLdr32.EXE
# tools:
# - JWasm/Masm
# - LINK.EXE: 32-bit MS coff linker
# - LINK16.EXE: 16-bit MS omf linker

!include <..\dirs>

!ifndef DEBUG
DEBUG=0
!endif

!if $(DEBUG)
OUTDIR=DEBUG
AOPTD=-D_DEBUG=1
!else
OUTDIR=RELEASE
AOPTD=
!endif

NAME=HXLDR32
MZNAME=hxldrmz
PENAME=hxldrpe
#LINK16=link16
LINK16=$(LINK16BIN)
LINK=$(LINKBIN)

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).exe $(OUTDIR)\HXDOSLD.EXE

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).EXE: $(OUTDIR)\$(MZNAME).exe $(OUTDIR)\$(PENAME).obj makefile
    $(LINK) @<<
$(OUTDIR)\$(PENAME).obj $(LIBCOFF)\dkrnl32.lib
/OUT:$*.EXE
/SUBSYSTEM:CONSOLE /STUB:$(OUTDIR)\$(MZNAME).exe
/HEAP:0x0,0x0 /STACK:0x1000,0x1000 /SECTION:.text,ERW
/FIXED /MAP
<<
!if $(DEBUG)==0
    @copy $*.EXE ..\..\Bin\*.* >NUL
!ifdef TOOLSDIR
    @copy $*.EXE $(TOOLSDIR)\*.*
!endif
!endif

$(OUTDIR)\$(PENAME).obj: $(PENAME).asm $(NAME).inc makefile
    $(ASM) -nologo -c -coff -Sg -Fl$* -Fo$* -I$(INC32DIR) $(PENAME).asm

# hxldrmz.exe will be a MZ stub. It cannot be linked with OPTLINK,
# because OPTLINK doesn't know the /KNOWEAX option!

$(OUTDIR)\$(MZNAME).exe: $(OUTDIR)\$(MZNAME).obj makefile
   @link16 $(OUTDIR)\$(MZNAME).obj /KNOWEAS/NON/MAP:FULL/ST:1024,$*,$*;
   @..\..\Bin\SHRMZHDR.EXE $*.EXE

$(OUTDIR)\$(MZNAME).obj: $(MZNAME).asm $(NAME).inc makefile
    $(ASM) -nologo -c -Fl$* -Fo$* -Sg $(AOPTD) -D?32BIT=1 -I$(INC32DIR) $(MZNAME).asm

$(OUTDIR)\HXDOSLD.EXE: $(OUTDIR)\HXDOSLD.OBJ makefile
	$(DMCDIR)\link $*.OBJ,$*.EXE,$*.map /NON/NOD/NOE;
!if $(DEBUG)==0
    @copy $*.EXE ..\..\Bin\*.* >NUL
!ifdef TOOLSDIR
    @copy $*.EXE $(TOOLSDIR)\*.*
!endif
!endif

$(OUTDIR)\HXDOSLD.obj: HXDOSLD.asm makefile
    $(ASM) -c -Fl$* -Fo$* $(AOPTD) HXDOSLD.asm

clean:
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.exe
	@del $(OUTDIR)\*.lst
