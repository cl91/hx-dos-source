
# makefile creates Sample2w.exe, enter
#   wmake /f sample2w.mak
# Open Watcom compiler and linker are used
# to prepare for debugging with WD on source level create the binary with:
#   wmake /f sample2w.mak debug=1

# Please note: you must have selected OS/2 as target platform
# when installing OW, else the linker will not find all libraries
# required to build the sample

!ifdef DEBUG
COPTD=-d2
LOPTD=debug dwarf
!else
COPTD=
LOPTD=
!endif

NAME=SAMPLE2
DUAL=1
CC=wcc.exe 
LINK=wlink.exe

!if $(DUAL)
$(NAME)W.EXE: $(NAME)W.obj $(NAME)W.mak
    $(LINK) $(LOPTD) file $(NAME)W.obj LibPath ..\Lib16 system hx16dm name $(NAME)W.EXE opt map,heapsize=4096 
!else
$(NAME)W.EXE: $(NAME)W.obj $(NAME)W.mak
    $(LINK) $(LOPTD) file $(NAME)W.obj LibPath ..\Lib16 system hx16 name $(NAME)W.EXE opt map,heapsize=4096 
    ..\Bin\patchNE $(NAME)W.EXE
!endif

$(NAME)W.OBJ: $(NAME).c
    $(CC) $(COPTD) -fo=$(NAME)W.obj $(NAME).c

