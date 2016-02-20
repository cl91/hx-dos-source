
# this nmake makefile creates MSHELP.OBJ
# enter: nmake 

# define directory for 16bit OMF libs/modules
LIBOMF16=..\..\lib16

!ifdef DEBUG
AOPTD=-Zi
!else
AOPTD=
!endif

OUTDIR=RELEASE

AOPT= -c -nologo -Sg -Fl$* -Fo$*.OBJ $(AOPTD) -I..\..\Include

ALL: $(OUTDIR)\MSHELP.OBJ

$(OUTDIR)\MSHELP.OBJ: mshelp.asm makefile
	ml $(AOPT) MSHELP.ASM
	copy $*.OBJ $(LIBOMF16)\*.*
    
