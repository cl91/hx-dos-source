
# nmake makefile. creates WSOCK32.DLL with OW

# Please note that some modules in wattcpwf.lib have to be modified.
# Since it is not allowed to distribute modified WatTCP modules in
# source/object format without the written permission of Erick Engelke,
# these modules are lacking here. In consequence, HX's WSOCK32.DLL
# in fact is only available in binary format currently. But with this source
# you may nevertheless get an idea how the implementation works.

# directory where WATT-32 is installed
WATT32=\watt32

!include <..\dirs>

!ifndef DEBUG
DEBUG=0
!endif

NAME=WSOCK32

!if $(DEBUG)
OUTDIR=DEBUG
COPTD=-D_DEBUG
#WTLIB=$(WATT32)\lib\wattcpwd.lib
WTLIB=$(WATT32)\lib\wattcpwf.lib
!else
OUTDIR=RELEASE
COPTD=
WTLIB=$(WATT32)\lib\wattcpwf.lib
!endif

CC=wcc386.exe -mf -w6 -3r -zq -bt=dos -bm -bd -ox -I$(WATT32)\inc -fo=$* $(COPTD)
#CC=wcc386.exe -mf -w6 -3r -zq -bt=nt -bm -bd -ox -I$(WATT32)\inc -fo=$* $(COPTD)
LINK=wlink.exe
LIBRARY = library $(WTLIB)

ALL: $(OUTDIR) $(OUTDIR)\$(NAME).DLL

$(OUTDIR):
	@mkdir $(OUTDIR)

$(OUTDIR)\$(NAME).DLL: $(OUTDIR)\$(NAME).OBJ $(WTLIB) $(NAME).RSP
#	@set WATCOM=$(OWDIR)
	@$(LINK) @<<
format windows nt dll
libpath %WATCOM%/lib386/nt
libpath %WATCOM%/lib386
option quiet, verbose, eliminate, caseexact, map=$(OUTDIR)\$(NAME).map, implib=$(OUTDIR)\$(NAME).lib
library clib3r.lib
library ..\..\LibOMF\hxowdll.lib
library $(LIBCOFF)\dkrnl32.lib
!if $(DEBUG)
library $(LIBCOFF)\duser32.lib
!endif
file $(OUTDIR)\$(NAME).OBJ
$(LIBRARY)
name $(OUTDIR)\$(NAME).DLL
@$(NAME).rsp
<<
!if $(DEBUG)==0
	@copy $*.DLL ..\..\bin\*.* >NUL
!ifdef DLL32DIR
	@copy $*.DLL $(DLL32DIR)\*.* >NUL
!endif    
!endif

$(OUTDIR)\$(NAME).OBJ: $(NAME).C MAKEFILE VERSION.H
	@set INCLUDE=$(OWDIR)\h\nt;$(OWDIR)\h;
	@$(CC) $(NAME).C

clean:
	@del $(OUTDIR)\*.obj
	@del $(OUTDIR)\*.dll
	@del $(OUTDIR)\*.lib
	@del $(OUTDIR)\*.lst
