
# nmake makefile, enter
#    nmake
# or, with symbolic debugging info:
#    nmake debug=1
# for source level debugging with WD use wlink instead of MS link (MSLINK=0)
# WD must be started with parameter /swap on plain DOS

name = plasma32
MSLINK=1

!ifdef DEBUG
AOPTD=-Zi -DDEBUG
LOPTDM=/DEBUG:FULL
LOPTDW=debug dwarf
!else
AOPTD=
LOPTDM=/DEBUG:NONE
LOPTDW=
!endif

ASM = ml -c -coff -nologo -Fo$* $(AOPTD)

!if $(MSLINK)
LIBS= kernel32.lib user32.lib ddraw.lib
LOPT=/OUT:$*.exe /SUBSYSTEM:CONSOLE $(LOPTDM) /FIXED:NO /NOLOGO
LINK=link.exe
MODS=$*.obj
!else
LOPT=system nt $(LOPTDW) name $*.exe opt map opt start=_start opt stack=0x8000
MODS=file $*.obj
LIBS=library ddraw.lib
LINK=wlink.exe
!endif

$(name).exe: $*.obj
    $(LINK) $(MODS) $(LIBS) $(LOPT)

$(name).obj: $(name).asm Makefile
     $(ASM) $(name).asm

