
# Nmake makefile to generate the HX dos extender binaries.

# Required tools are:
#
# tool         name         recommended       optional
# --------------------------------------------------------------
# Make                      MS NMake          OW WMake -ms
# Assembler    $(ASM)       JWasm             Masm v6.14+
# COFF linker               JWlink            MS LINK
# COFF lib     $(LIBBIN)    OW WLib           MS LIB
# COFF RC      $(RCBIN)     OW WRC            MS RC
# OMF linker   $(LINK16BIN) JWlink            MS LINK (OMF)
# OMF lib      $(LIB16BIN)  OW WLib           MS LIB (OMF)

# JWasm and JWlink can be found at http://www.japheth.de.
# The Open Watcom (OW) tools WLib and WRC may also be found
# there - or just download the full OW package.

# About WSOCK32 target:
# The WSOCK32 target has to be excluded, because some object
# modules are currently missing due to copyright restrictions.
# WSOCK32 is written in C, and requires:
# - OW 32bit C compiler (wcc386.exe)
# - JWlink (jwlink.exe)
# - watt-32 library (WATTCPWD.LIB) compiled with open watcom,
# - OW CRT with register calling convention (clib3r.lib)

!include <dirs>

!ifndef DEBUG
DEBUG = 0
!endif

ALL: 
    cd    HDPMI
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\DPMILDR
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\NTLFNHLP
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\DKRNL32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\DADVAPI
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\DGDI32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\DUSER32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\DDDRAW
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\OLE32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\OLEAUT32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\VERSION
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\VESA32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\HXLDR32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\PESTUB
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\HXGUIHLP
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\SB16
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\WINMM
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\DINPUT
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\DSOUND
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\WSOCK32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\WS2_32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\DCIMAN32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\MSACM32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\MPR
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\IPHLPAPI
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\SHELL32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\COMCTL32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\COMDLG32
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\STUBS
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\MZSUPP
    @$(MAKE) DEBUG=$(DEBUG) 
#    cd ..\NESUPP
#    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\HXHELP
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\PATCHPE
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\PATCHNE
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..\SHDPMI
    @$(MAKE) DEBUG=$(DEBUG) 
    cd ..

clean: 
    cd    HDPMI
    @$(MAKE) DEBUG=$(DEBUG) clean
    cd ..\DPMILDR
    @$(MAKE) DEBUG=$(DEBUG) clean
    cd ..\NTLFNHLP
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\DKRNL32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\DADVAPI
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\DGDI32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\DUSER32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\DDDRAW
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\OLE32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\OLEAUT32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\VERSION
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\VESA32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\HXLDR32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\PESTUB
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\HXGUIHLP
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\SB16
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\WINMM
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\DINPUT
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\DSOUND
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\WSOCK32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\WS2_32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\DCIMAN32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\MSACM32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\MPR
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\IPHLPAPI
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\MZSUPP
    @$(MAKE) DEBUG=$(DEBUG) clean 
#    cd ..\NESUPP
#    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\STUBS
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\HXHELP
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\PATCHPE
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\PATCHNE
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\SHDPMI
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\SHELL32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\COMCTL32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..\COMDLG32
    @$(MAKE) DEBUG=$(DEBUG) clean 
    cd ..
