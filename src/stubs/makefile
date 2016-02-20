
# nmake makefile
# creates stubs: DPMILD32.BIN, DPMILD16.BIN, LOADPE.BIN, LOADPEX.BIN
# for HX 32-bit and 16-bit applications
# use MS 16-bit linker and tool shrmzhdr.exe
# using Digital Mars C++ linker currently not supported!

!include <..\dirs>

DEVDRV = 0

NAME16=DPMIST16
NAME32=DPMIST32

!ifndef DEBUG
DEBUG=0
!endif

!if $(DEBUG)
OUTDIR=Debug
!else
OUTDIR=Release
!endif

!ifndef MASM
MASM=0
!endif

!if $(MASM)
ASM=@ml.exe
!else
ASM=@jwasm.exe
!endif

LOPT=/NOLOGO/NON/MAP:FULL/KNOWEAS/ST:1024

ALL: $(OUTDIR) $(OUTDIR)\$(NAME32).BIN $(OUTDIR)\$(NAME16).BIN $(OUTDIR)\LOADPE.BIN $(OUTDIR)\LOADPEX.BIN

$(OUTDIR):
	@mkdir $(OUTDIR)

#--- DPMILD32.BIN

$(OUTDIR)\$(NAME32).BIN: $*.obj Makefile
!if 1
    link16 $*.obj $(LOPT), $*.BIN, $*.MAP;
    ..\..\Bin\shrmzhdr $*.BIN
!else
    $(DMCDIR)\link.exe $* /NON/MAP:FULL/ST:1024,$*.BIN,$*.MAP;
!endif
!if $(DEBUG)==0
    @copy $*.BIN ..\..\Bin\*.* >NUL
!ifdef TOOLSDIR
     @copy $*.BIN $(TOOLSDIR)\*.*
!endif
!endif

$(OUTDIR)\$(NAME32).obj: dpmistub.asm Makefile
    $(ASM) -c -nologo -Fl$* -Fo$* -D?DEVDRV=$(DEVDRV) -D?32BIT=1 -I..\..\Include dpmistub.asm

#--- DPMILD16.BIN

$(OUTDIR)\$(NAME16).BIN: $*.obj Makefile
    link16 $*.obj $(LOPT), $*.BIN, $*.MAP;
    ..\..\Bin\shrmzhdr $*.BIN
!if $(DEBUG)==0
    @copy $*.BIN ..\..\Bin\*.* >NUL
!ifdef TOOLSDIR
     @copy $*.BIN $(TOOLSDIR)\*.*
!endif
!endif

$(OUTDIR)\$(NAME16).obj: dpmistub.asm Makefile
    $(ASM) -c -nologo -Fl$* -Fo$* -D?DEVDRV=$(DEVDRV) -D?32BIT=0 -I..\..\Include dpmistub.asm

LOPT2=/NOLOGO/NON/MAP:FULL/KNOWEAS

#--- LOADPE.BIN

$(OUTDIR)\LOADPE.BIN: $*.obj Makefile
    link16 $*.obj $(LOPT2), $*.BIN, $*.MAP, ..\..\LibOMF\jmppm32.lib;
    ..\..\Bin\shrmzhdr $*.BIN
!if $(DEBUG)==0
    @copy $*.BIN ..\..\Bin\*.* >NUL
!ifdef TOOLSDIR
     @copy $*.BIN $(TOOLSDIR)\*.*
!endif
!endif
    
$(OUTDIR)\LOADPE.obj: LoadPE.asm Makefile
    $(ASM) -c -nologo -Fl$* -Fo$* -I..\..\Include LoadPE.asm

#--- LOADPEX.BIN

$(OUTDIR)\LOADPEX.BIN: $*.obj Makefile
    link16 $*.obj $(LOPT2), $*.BIN, $*.MAP, ..\..\LibOMF\jmppm32.lib;
    ..\..\Bin\shrmzhdr $*.BIN
!if $(DEBUG)==0
    @copy $*.BIN ..\..\Bin\*.* >NUL
!ifdef TOOLSDIR
     @copy $*.BIN $(TOOLSDIR)\*.*
!endif
!endif
    
$(OUTDIR)\LOADPEX.obj: LoadPE.asm Makefile
    $(ASM) -c -nologo -D?HDPMI=1 -Fl$* -Fo$* -I..\..\Include LoadPE.asm

clean:
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.bin
	@del $(OUTDIR)\*.lst
	@del $(OUTDIR)\*.map
