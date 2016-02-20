
# this nmake makefile creates JMPPM16.OBJ and JMPPM16W.OBJ
# enter: nmake 

# define name of OMF lib utility (not used currently)
#LIB=$(LIB16BIN)

# define directory for 16bit OMF libs/modules

!include <..\dirs>

LIBOMF16=..\..\lib16

!ifdef DEBUG
AOPTD=-Zi
!else
AOPTD=
!endif

OUTDIR=RELEASE

AOPT= -c -nologo -Sg -Fl$* -Fo$*.OBJ $(AOPTD) -I$(INC32DIR)

ALL: $(OUTDIR)\JMPPM16.OBJ $(OUTDIR)\JMPPM16W.OBJ $(OUTDIR)\JMPPM16M.OBJ

$(OUTDIR)\JMPPM16.OBJ: jmppm16.asm makefile
	$(ASM) $(AOPT) -D?C=0 JMPPM16.ASM
	copy $*.OBJ $(LIBOMF16)\*.*
    
$(OUTDIR)\JMPPM16W.OBJ: jmppm16.asm makefile relocs.inc
	$(ASM) $(AOPT) -D?C=1 -D?OW=1 JMPPM16.ASM
	copy $*.OBJ $(LIBOMF16)\*.*

$(OUTDIR)\JMPPM16M.OBJ: jmppm16.asm makefile relocs.inc
	$(ASM) $(AOPT) -D?C=1 -D?MS=1 JMPPM16.ASM
	copy $*.OBJ $(LIBOMF16)\*.*
