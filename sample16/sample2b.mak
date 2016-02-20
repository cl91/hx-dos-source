
# creates Sample2b.exe
# - compiled with Borland C++ (adjust the path for the include files!)
# - linked with TLINK
# only the 16-bit large memory model is supported by Borland's PowerPack

!ifdef DEBUG
COPTD=-v
LOPTDM=/CO
LOPTDB=-v
!else
COPTD=
LOPTDM=
LOPTDB=
!endif

USEMSCLIBS=0

NAME=SAMPLE2
CC=bcc.exe -c -ml -2 $(COPTD) -o$* -I\bc4\include
LINK=tlink.exe
LOPTS=-3 -Tx -s -L\bc4\lib $(LOPTDB)
LIBS=dpmi16.lib cwl.lib 

$(NAME)B.EXE: $*.obj $*.def $*.mak
    $(LINK) $(LOPTS) c0x.obj $*,$*.EXE,$*.map,$(LIBS),$*.def
    ..\Bin\patchNE $*.EXE

$(NAME)B.OBJ: $(NAME).C $*.mak
    $(CC) $(NAME).C

