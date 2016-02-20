
# makefile to be used with NMAKE, will create SAMPLE8.EXE, enter
#   nmake /f sample8.mak
# MS MASM and MS OMF linker (renamed to link16.exe) are used.
# output will be a 16 bit OS/2 binary. To run it enter
#   DPMILD16 SAMPLE8
#
# the binary can be "bound" to make it a FAPI application which
# runs both in real-mode and protected-mode

NAME=SAMPLE8
BIND=0

!ifdef DEBUG
AOPTD=-Zi
LOPTD=/CO
!else
AOPTD=
LOPTD=
!endif

AS=ml -c -Fo$(NAME) -I..\include $(AOPTD)
LIBS= OS2.LIB
LOPTS=/NOD/NOE/NON/A:16/MAP:FULL/FAR/ONERROR:NOEXE $(LOPTD)

$(NAME).EXE: $(NAME).obj $(NAME).def $(NAME).mak
    link16.exe @<<
$(NAME).obj $(LOPTS), $(NAME).EXE, $(NAME).map, $(LIBS), $(NAME).def
<<
!if $(BIND)
	bind $(NAME).EXE
!endif

$(NAME).obj: $(NAME).asm $(NAME).mak
    $(AS) $(NAME).asm

