
# nmake makefile to build sample2p.exe, enter:
#    nmake /f sample2p.mak
# to add debug info enter:
#    nmake /f sample2p.mak debug=1

# PoASM + Polink are used

NAME=Sample

!ifdef DEBUG
AOPTD=-Zi
LOPTD=/DEBUG
!else
AOPTD=
LOPTD=
!endif

ASM=poasm.exe
LINK=polink.exe

ASMOPT= -Fo$* -D?POASM -I..\..\Include $(AOPTD)

# set LIBPATH variable to let linker find the Win32 COFF libraries
#LIBPATH=\PSDK\Lib
LIBPATH=..\..\Lib

# patchPE is commented out here because app is a true Win32 app

$(NAME)P.EXE: $*.obj $*.mak
    $(LINK) $*.obj /LIBPATH:$(LIBPATH) dkrnl32.lib /OUT:$*.EXE /SUBSYSTEM:CONSOLE /STUB:..\..\bin\dpmist32.bin /FIXED:NO $(LOPTD)
#   ..\..\bin\patchPE $*.EXE

$(NAME)P.OBJ: $(NAME).asm $*.mak
    $(ASM) $(ASMOPT) $(NAME).asm

