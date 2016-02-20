
# create a DOS-PE with Win32 emulation linked statically
# tools:
# - MASM v6
# - MS LINK or POLINK

# initw32.obj: used to initialize the win32 emulation
# loadpe.bin: avoids need of DPMILD32.EXE, thus this
# binary will run stand-alone if a DPMI host is available

NAME=Sample
LINK=polink

ASMOPT= -c -coff -Fo$* /I..\..\Include
LOPT=/fixed:no /map /stub:..\..\Bin\LOADPE.BIN /OUT:$*.exe /LIBPATH:..\..\Lib
LIBS=dkrnl32s.lib duser32s.lib imphlp.lib

$(NAME)MS.EXE: $*.obj
    $(LINK) ..\..\Lib\initw32.obj $* $(LOPT) $(LIBS)
    patchpe $*.exe

$(NAME)MS.OBJ: $(NAME).asm $*.mak
    ml $(ASMOPT) $(NAME).asm
