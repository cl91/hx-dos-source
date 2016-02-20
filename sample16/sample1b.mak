
# makefile to be used with NMAKE, enter
#   nmake /f sample1b.mak
# uses TASM and TLINK
# output will be in NE file format
# to create a binary with debug information enter  
#   nmake /f sample1b.mak debug=1

NAME=SAMPLE1

!ifdef DEBUG
AOPTD=-zi
LOPTD=/v
!else
AOPTD=
LOPTD=
!endif

AS=tasm.exe -ml -i..\include $(AOPTD)
LIBS= ..\lib16\kernel16.lib
LOPTS= /3 /A=16 /Tx $(LOPTD)

$(NAME)b.exe: $*.obj $(NAME).def $*.mak
    tlink.exe @<<
$(LOPTS) $*.obj,$*.EXE,$*.MAP,$(LIBS),$(NAME).def
<<
	..\Bin\patchNE.exe -v $*.exe

$(NAME)b.obj: $(NAME).asm $*.mak
    $(AS) $(NAME).asm,$*;

