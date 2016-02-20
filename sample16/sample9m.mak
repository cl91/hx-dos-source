
# nmake makefile, will create Sample9m.exe, enter:
#   nmake /f sample9m.mak
# will be compiled and linked with VC 1.5 command line tools, the MS
# OMF linker link.exe is renamed to link16.exe!
#
# the MS VC 16-bit CRT for windows binaries (SLIBCEW.LIB) is used here
# but since this lib doesn't support printf, a small helper SLX.LIB
# has to be used.
# patchNE will mark the binary as DPMI16 application, so it won't be
# loaded as 16-bit windows application.
# to prepare for source level debugging with WD create the binary with:
#   nmake /f sample9m.mak debug=1

!ifdef DEBUG
COPTD=-Zi
LOPTD=/CO
!else
COPTD=
LOPTD=
!endif

NAME=SAMPLE9

CC=cl.exe -c -AS -G3 -Ozw -W3 -Fo$* -DSTRICT $(COPTD)
LINK=link16.exe
LIBS=..\Lib16\kernel16.lib ..\Lib16\slx.lib slibcew.lib
LOPTS=/NOLOGO/NOD/NOE/NON/A:16/MAP:FULL/FAR/ONERROR:NOEXE $(LOPTD)

$(NAME)M.EXE: $*.obj $(NAME).def $*.mak
    $(LINK) @<<
$*.obj $(OBJS) $(LOPTS),$*.EXE,$*.map,$(LIBS),$(NAME).def
<<
    ..\Bin\patchNE $*.EXE

$(NAME)M.obj: $(NAME).c $*.mak
    $(CC) $(NAME).c

