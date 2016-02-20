
# nmake makefile to build sample1m.exe, enter
#   nmake /f samplem.mak
# for a binary with debug info enter:
#   nmake /f samplem.mak debug=1

# uses MASM + MS link

!ifdef DEBUG
AOPTDM=-Zi
LOPTDM=/DEBUG
!else
AOPTDM=
LOPTDM=
!endif

NAME=Sample

STUB=..\..\bin\dpmist32.bin
#STUB=..\..\bin\loadpe.bin
#STUB=..\..\bin\loadpex.bin
#STUB=..\..\bin\dpmild32.bin
#STUB=..\..\bin\hdld32.bin

AS=ml.exe
ASMOPT= -c -coff -Fo$*.obj $(AOPTDM)
LINK=polink.exe
LPARAM=$*.obj /NOLOGO /OUT:$*.exe /SUBSYSTEM:CONSOLE /STUB:$(STUB) /FIXED:NO /HEAP:0 /STACK:0x1000 $(LOPTDM)

# patchPE is used here to ensure app is executed as DPMI client

$(NAME)M.exe: $*.obj $*.mak
    $(LINK) @<<
$(LPARAM)
<<
    ..\..\Bin\patchPE $*.exe

$(NAME)M.obj: $(NAME).asm $*.mak
    $(AS) $(ASMOPT) $(NAME).asm

