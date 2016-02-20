
# NMAKE makefile, creates Sample1w.exe, enter
#   nmake /f sample2w.mak
# Open Watcom's WASM and WLINK are used
# to create a version with debug information included enter:
#   nmake /f sample2w.mak debug=1

NAME=SAMPLE1

!ifdef DEBUG
AOPTD=-d2
LOPTD=debug dwarf
!else
AOPTD=
LOPTD=
!endif

AS=wasm.exe 
LINK=wlink.exe

$(NAME)W.EXE: $(NAME)W.obj $(NAME)W.mak
    $(LINK) $(LOPTD) file $(NAME)W.obj system windows opt map opt stub=..\Bin\DPMIST16.BIN name $(NAME)W.EXE
    ..\Bin\patchNE $(NAME)W.EXE

$(NAME)W.OBJ: $(NAME).asm
    $(AS) $(AOPTD) -fo=$(NAME)W.obj $(NAME).asm

