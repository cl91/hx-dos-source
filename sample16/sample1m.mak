
# makefile to be used with NMAKE, will create SAMPLE1M.EXE, enter
#   nmake /f sample1m.mak
# MS MASM and MS OMF linker (renamed to link16.exe) are used.
# output will be in NE file format
# to create a binary prepared for source level debugging with WD enter:
#   nmake /f sample1m.mak debug=1

NAME=SAMPLE1

!ifdef DEBUG
AOPTD=-Zi
LOPTD=/CO
!else
AOPTD=
LOPTD=
!endif

AS=ml -c -Fo$* -I..\include -D?MASM=1 $(AOPTD)
LIBS= ..\lib16\kernel16.lib
LOPTS=/NOD/NOE/NON/A:16/MAP:FULL/FAR/ONERROR:NOEXE $(LOPTD)

$(NAME)M.exe: $*.obj $(NAME).def $*.mak
    link16.exe @<<
$*.obj $(LOPTS),$*.EXE,$*.map,$(LIBS),$(NAME).def
<<
	..\Bin\patchNE.exe $*.EXE

$(NAME)M.obj: $(NAME).asm $*.mak
    $(AS) $(NAME).asm

