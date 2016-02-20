
# makefile to be used with NMAKE, to create the binary enter
#   nmake /f sample2d.mak
# this will create SAMPL2D.EXE, a HX 16-bit binary in NE format
#
# Digital Mars C++ and LINK are used. I couldn't find a 16-bit
# C runtime library for protected mode supplied with DM (possibly there
# is one on the DM CD), but since this compiler is very MS compatible 
# the MS VC 1.5 lib (SLIBCEW) is used here.
#
# patchNE will mark the binary as DPMI16 application, so it won't be
# loaded as 16-bit windows application.

!ifdef DEBUG
COPTD=-g
LOPTD=/CO
!else
COPTD=
LOPTD=
!endif

NAME=SAMPLE2

CC=\dm\bin\dmc.exe -c -mso -3 -o -o$* -DSTRICT $(COPTD)
LINK=\dm\bin\link.exe
LIBS=..\Lib16\kernel16.lib ..\Lib16\slx.lib c:\msvc\lib\slibcew.lib
LOPTS=/NOLOGO/NOD/NOE/NON/A:16/MAP:FULL/FAR/ONERROR:NOEXE $(LOPTD)

$(NAME)D.EXE: $*.obj $(NAME).def $*.mak
    $(LINK) @<<
$*.obj $(OBJS) $(LOPTS),$*.EXE,$*.map,$(LIBS),$(NAME).def
<<
    ..\Bin\patchNE $*.EXE

$(NAME)D.obj: $(NAME).c $*.mak
    $(CC) $(NAME).c

