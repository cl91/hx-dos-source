
# nmake makefile to build sample2m.exe, enter:
#    nmake /f sample2m.mak
# to add debug info enter:
#    nmake /f sample2m.mak debug=1

# MASM + MS link are used

NAME=Sample

!ifdef DEBUG
AOPTD=-Zi
LOPTD=/DEBUG
!else
AOPTD=
LOPTD=
!endif

# to make a 32bit DOS-PE binary instead of a Win32-PE, set DOS=1.

DOS=0

ASM=ml.exe
LINK=link.exe

ASMOPT= -c -coff -nologo -Fo$* -I..\..\Include $(AOPTD)

# set LIBPATH variable to let linker find the Win32 COFF libraries

LIBPATH=..\..\Lib

# if a DOS-PE is created, link the PE loader statically into the binary.
# linking the Win32 kernel code statically would require source code 
# modifications, since the kernel code needs initialization.

!if $(DOS)
STUB=dpmild32.bin
!else
STUB=dpmist32.bin
!endif

# patchPE is to be used for DOS-PEs only 

$(NAME)M.EXE: $*.obj $*.mak
    $(LINK) $*.obj dkrnl32.lib /NOLOGO /MAP /OUT:$*.EXE /SUBSYSTEM:CONSOLE /LIBPATH:$(LIBPATH) /STUB:..\..\bin\$(STUB) /FIXED:NO $(LOPTD)
!if $(DOS)    
    ..\..\bin\patchPE $*.EXE
!endif    

$(NAME)M.OBJ: $(NAME).asm $*.mak
    $(ASM) $(ASMOPT) $(NAME).asm

