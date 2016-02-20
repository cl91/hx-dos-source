
# makefile to be used with NMAKE, to create the binary enter
#    nmake /f smpl2mzd.mak
# this will create SMPL2MZD.EXE, a HX 16-bit binary in MZ format
#
# Digital Mars C++ and LINK are used. I couldn't find a 16-bit
# C runtime library for protected mode supplied with DM (possibly there
# is one on the DM CD), but since this compiler is very MS compatible 
# the MS VC 1.5 lib (SLIBCEW) is used here.
#
# Other modules:
# JMPPM16M.OBJ: this is the first startup module to switch to protected mode

DMLINK=1

!ifdef DEBUG
COPTD=-g
LOPTDD=/CO
!else
COPTD=
LOPTDD=
!endif

NAME=SMPL2MZD
SNAME=SAMPLE2

CC=\dm\bin\dmc -c $(COPTD) -mso -3 -o -I=..\include -o$* 

LINK=\dm\bin\link.exe
LIBS=..\Lib16\slx.lib c:\msvc\lib\slibcew.lib
LOPTS=/NON/NOE/ONE:NOE/MAP/PACKC/FAR $(LOPTDD)
LIB=
OBJS=..\Lib16\mshelp.obj

$(NAME).EXE: $*.obj $*.mak
    $(LINK) $(LOPTS) ..\lib16\jmppm16m.obj $*.OBJ $(OBJS),$*.EXE,$*.MAP,$(LIBS);

$(NAME).obj: $(SNAME).c $*.mak
    $(CC) $(SNAME).c

