
# makefile to be used with NMAKE, to create the binary enter
#    nmake /f smpl1mz.mak
# created binary will be in simple DOS MZ format

# JWasm/Masm and MS OMF linker (renamed to link16.exe) are used
# optionally one may use Open Watcom WASM and WLINK

USEMASM=1

NAME=SMPL1MZ

!if $(USEMASM)

#AS=ml -Zi -c -Sg -Fo$* -I..\include
AS=jwasm -Zi -c -Sg -Fo$* -I..\include
LINK=link16.exe
LIBS= 
LOPTS=/NOD/NOE/NON/MAP:FULL/ONERROR:NOEXE/STACK:1024/CO
LPARAMS=..\lib16\jmppm16.obj $*.OBJ $(LOPTS),$*.EXE,$*.MAP,$(LIBS);
!else

AS=wasm -zcm -d2 -fo=$* -i=..\include
LINK=wlink.exe
LIBS=
LOPTS=system dos opt stack=1024
LPARAMS=debug dwarf file ..\lib16\jmppm16.obj, $*.OBJ $(LOPTS) name $*.EXE opt map=$*.MAP $(LIBS)
!endif


$(NAME).EXE: $*.obj $*.mak
    $(LINK) @<<
$(LPARAMS)
<<

$(NAME).obj: $*.asm $*.mak
    $(AS) $*.asm

