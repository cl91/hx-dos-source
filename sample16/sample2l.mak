
# nmake makefile, will create Sample2l.exe, enter:
#   nmake /f sample2l.mak
# will be compiled and linked with VC 1.5 command line tools, the MS
# OMF linker link.exe is renamed to link16.exe!
#
# this makefile compiles sample2.c with large model
# the MS VC 16-bit CRT for windows binaries (LLIBCEW.LIB) is used here
# but since this lib doesn't support printf, a small helper LLX.LIB
# has to be used.
# patchNE will mark the binary as DPMI16 application, so it won't be
# loaded as 16-bit windows application.
# to prepare for source level debugging with WD create the binary with:
#   nmake /f sample2l.mak debug=1

!ifdef DEBUG
COPTD=-Zi
LOPTD=/CO
!else
COPTD=
LOPTD=
!endif

NAME=SAMPLE2L
SNAME=SAMPLE2

CC=cl.exe -c -AL -G3 -Ozw -W3 -Fo$* -DSTRICT $(COPTD)
LINK=link16.exe
LIBS=..\Lib16\kernel16.lib ..\Lib16\llx.lib llibcew.lib
LOPTS=/NOLOGO/NOD/NOE/NON/A:16/MAP:FULL/ONERROR:NOEXE $(LOPTD)

$(NAME)M.EXE: $*.obj $(SNAME).def $*.mak
    $(LINK) @<<
$*.obj $(OBJS) $(LOPTS),$*.EXE,$*.map,$(LIBS),$(SNAME).def
<<
    ..\Bin\patchNE $*.EXE

$(NAME)M.obj: $(SNAME).c $*.mak
    $(CC) $(SNAME).c

