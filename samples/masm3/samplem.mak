
# create a Win32 binary
# tools:
# - MASM v6
# - MS LINK or POLINK

NAME=Sample
LINK=polink

ASMOPT= -c -coff -Fo$* /I..\..\Include
LOPT=/fixed:no /map /stub:..\..\Bin\DPMIST32.BIN /OUT:$*.exe /LIBPATH:..\..\Lib
LIBS=dkrnl32.lib duser32.lib

$(NAME)M.EXE: $*.obj
    $(LINK) $* $(LOPT) $(LIBS)

$(NAME)M.OBJ: $(NAME).asm $*.mak
    ml $(ASMOPT) $(NAME).asm
