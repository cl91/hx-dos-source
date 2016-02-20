
# nmake makefile, create sample3.exe, enter
#    nmake /f sample3.mak
# MS 16-bit cobol compiler and MS OMF linker are used
# libs used:
# ..\Lib16\kernel16.lib: win31 kernel emulation of DPMILD16.exe
# ..\Lib16\dosxxxs.lib: static lib for HX's OS/2 emulation
# lcobol.lib: MS cobol static runtime lib

# one might also link with dosxxx.lib instead of dosxxxs.lib
# (the patchNE step should be deactivated then).
# This allows to link the app as a OS/2 16bit binary
# which DPMILD16 is able to load in DOS with the help of the emulation dlls
# found in this directory. In OS/2 it will run as native OS/2 app then.


!ifdef DEBUG
LOPTD=/CO
!else
LOPTD=
!endif

PGM=SAMPLE3
LOPTS=/NOPACKC/MAP:FULL/NOD/NON/A:16/ON:N/FAR $(LOPTD)
LIBS=..\Lib16\kernel16.lib ..\Lib16\dosxxxs.lib lcobol.lib

$(PGM).EXE: $*.obj $*.mak $*.def
   link16 @<<
$(PGM) $(LOPTS),
$(PGM).EXE,
$(PGM).map,
$(LIBS),
$(PGM);
<<
	patchNE $(PGM).EXE
    
$(PGM).obj: $*.cbl
   cobol $*.cbl;

