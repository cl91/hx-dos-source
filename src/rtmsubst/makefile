
# NMAKE makefile which creates USER.DLL and RTM.DLL
# uses jwasm and MS OMF linker

!include <..\dirs>

name = USER
name2 = RTM

AS = $(ASM) -c -Cp -nologo -Fl$* -Fo$* -Sg -I..\..\Include
LOPTS=/MAP:FULL/A:16/FAR/NON/NOD/ONE:NOE
LIBS= ..\..\Lib16\kernel16 

OUTDIR=RELEASE

ALL: $(OUTDIR)\$(name).dll $(OUTDIR)\$(name2).DLL

#---------------------------------------------

$(OUTDIR)\$(name).DLL: $*.OBJ $(OUTDIR)\OUTPUT.OBJ $(name).DEF
	$(LINK16BIN) @<<
$*.OBJ $(OUTDIR)\output.obj $(LOPTS),
$*.DLL,
$*.MAP,
$(LIBS),
$(name).DEF
<<
	@copy $*.DLL ..\..\Bin\$(name).DLL >NUL
!ifdef DLL32DIR    
	@copy $*.DLL $(DLL32DIR)\$(name).DLL >NUL
!endif
#	implib /nowep $(OUTDIR)\USER16.LIB $*.DLL
#	copy $(OUTDIR)\USER16.LIB ..\..\lib16\*.*

$(OUTDIR)\$(name).OBJ: $(name).ASM MAKEFILE
	 $(AS) $(name).ASM

$(OUTDIR)\OUTPUT.OBJ: OUTPUT.ASM MAKEFILE
	$(AS) OUTPUT.ASM

#---------------------------------------------

$(OUTDIR)\$(name2).DLL: $*.OBJ $(name2).DEF
	$(LINK16BIN) @<<
$*.OBJ $(LOPTS),
$*.DLL,
$*.MAP,
$(LIBS),
$(name2).DEF
<<
	@copy $*.DLL ..\..\Bin\$(name2).DLL >NUL
!ifdef DLL32DIR
	@copy $*.DLL $(DLL32DIR)\$(name2).DLL >NUL
!endif
#	implib /nowep $(OUTDIR)\$(name2).LIB $*.DLL
#	copy $*.LIB ..\..\lib16\*.*

$(OUTDIR)\$(name2).OBJ: $(name2).ASM MAKEFILE
	$(AS) $(name2).ASM

#---------------------------------------------

clean:
	@del $(OUTDIR)\*.dll
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.map
	@del $(OUTDIR)\*.lst
