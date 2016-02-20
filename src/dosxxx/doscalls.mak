
# create OS/2 emulation dll DOSCALLS.DLL

NAME  = DOSCALLS
LOPTS = /NOPACKC/FAR/NON/NOD/NOE/MAP:FULL/A:16/ONERROR:NOEXE
LIBS  = ..\..\..\lib16\kernel16.lib .\dosxxxs.lib
MODS  = doscalls dosrallc

OUTDIR=RELEASE

$(OUTDIR)\$(NAME).DLL: $(NAME).def $(NAME).mak $*.obj $(OUTDIR)\dosrallc.obj $(OUTDIR)\dosxxxs.lib
	cd $(OUTDIR)
    link16.exe @<<
$(MODS),
$(NAME).DLL,
$(NAME).map,
$(LIBS),
..\$(NAME).def $(LOPTS);
<<
#    rc $(NAME).dll
#    c:\msvc\bin\implib -nowep $(NAME).lib ..\$(NAME).def
    cd ..

$(OUTDIR)\$(NAME).obj: $(NAME).asm
    jwasm.exe -c -Fl$* -Fo$* $(NAME).asm

$(OUTDIR)\dosrallc.obj: dosrallc.asm
    jwasm.exe -c -Fl$* -Fo$* dosrallc.asm

clean:
