
# makefile to be used to create the binary enter
#   nmake /f smpl2mzw.mak
# this will create SMPL2MZW.EXE, a HX 16-bit binary in MZ format
# to prepare for source level debugging with WD create the binary with:
#   nmake /f smpl2mzw.mak debug=1
#
# Open Watcom's WCC and WLINK are used.
#
# Other modules:
# JMPPM16W.OBJ: this is the first startup module to switch to protected mode.
#               for wlink, system hx16mz will include it automatically. 
# CSTRT16Z.OBJ: the second startup module. It is a slightly modified version
#               of the OW module CSTRTO16.ASM. For wlink, it has to be
#               added explicitely, else the linker will complain about
#               multiple start addresses found.

MSLINK=0

!ifdef DEBUG
COPTD=-d2
LOPTDM=/CO
LOPTDW=debug dwarf
!else
COPTD=
LOPTDM=
LOPTDW=
!endif

NAME=SMPL2MZW
SNAME=SAMPLE2

CC=wcc $(COPTD) -fo=$* -i=..\include

!if $(MSLINK)
LINK=link16.exe
LIBS=..\Lib16\dosxxxs.lib \watcom\lib286\os2\clibs.lib
LOPTS=/NON/NOE/ONE:NOE/NOD/MAP/PACKC/FAR $(LOPTDM)
LIB=\watcom\lib286;
OBJS=..\OWSupp16\cstrt16z.obj 

$(NAME).EXE: $(NAME).obj $(NAME).mak
    $(LINK) @<<
$(LOPTS) ..\lib16\jmppm16w.obj $(NAME).OBJ $(OBJS),$(NAME).EXE,$(NAME).MAP,$(LIBS);
<<

!else

$(NAME).EXE: $(NAME).obj $(NAME).mak
    wlink.exe @<<
LibPath ..\Lib16 system hx16mz $(LOPTDW) file $(NAME).OBJ,..\Lib16\cstrt16z.obj name $(NAME).EXE opt map
<<

!endif

$(NAME).obj: $(SNAME).c $(NAME).mak
    $(CC) $(SNAME).c

