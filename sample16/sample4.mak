
# nmake makefile, creates Sample4.exe, enter:
#    nmake /f sample4.mak
# will be compiled and linked with Open Watcom tools

NAME=SAMPLE4
CC=wcc.exe 
LINK=wlink.exe
DUAL=1
DEBUG=
#DEBUG=debug dwarf

!if $(DUAL)
$(NAME).EXE: $*.obj $*.mak
    $(LINK) LibPath ..\Lib16 $(DEBUG) file $*.obj system hx16dm name $*.EXE opt map,heapsize=4096
!else
$(NAME).EXE: $*.obj $*.mak
    $(LINK) LibPath ..\Lib16 $(DEBUG) file $*.obj system hx16 name $*.EXE opt map,heapsize=4096
    ..\Bin\patchNE $(NAME).EXE
!endif

$(NAME).OBJ: $(NAME).c
    $(CC) -d2 -bt=os2 -i\watcom\h\os21x -fo=$*.obj $(NAME).c

