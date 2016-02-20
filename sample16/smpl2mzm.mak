
# nmake makefile, will create Smpl2mzm.exe, enter:
#   nmake /f smpl2mzm.mak
# will be compiled and linked with VC 1.5 command line tools, the MS
# OMF linker link.exe is renamed to link16.exe!
#
# the MS VC 16-bit CRT for windows binaries (SLIBCEW.LIB) is used here
# but since this lib doesn't support printf, a small helper SLX.LIB
# has to be used.
# to prepare for source level debugging with WD create the binary with:
#   nmake /f smpl2mzm.mak debug=1

!ifdef DEBUG
COPTD=-Zi -Od -G2
LOPTD=/CO
!else
COPTD=-Ozw -G3 -Gs
LOPTD=
!endif

SNAME=SAMPLE2
NAME=SMPL2MZM

CC=cl.exe -c -AS -W3 -Fo$* -DSTRICT $(COPTD)
LINK=link16.exe
LIBS=..\Lib16\slx.lib slibcew.lib
LOPTS=/NOLOGO/NOD/NOE/NON/MAP:FULL/PACKC/FAR/ONERROR:NOEXE/ST:2048 $(LOPTD)
OBJS=..\Lib16\mshelp.obj 

$(NAME).EXE: $*.obj $*.mak
    $(LINK) @<<
..\lib16\jmppm16m.obj $*.obj $(OBJS) $(LOPTS),$*.EXE,$*.map,$(LIBS);
<<

$(NAME).obj: $(SNAME).c $*.mak
    $(CC) $(SNAME).c

