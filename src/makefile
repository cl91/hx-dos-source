
# nmake makefile to generate the hx dos extender binaries

# the WSOCK32 target has to be excluded, because some object
# modules are currently missing due to copyright restrictions

# tools required are:
#
# 1. Make
#    - NMake.EXE (MS)
#
# 2. Assembler, $(ASM)
#    - JWasm or
#    - MS Masm v6.14 | v6.15 | v7.00 | v8.00
#
# 3. COFF linker, $(LINKBIN)
#    - LINK.EXE (MS)
#   (- POLINK.EXE          - PellesC ) cannot be used yet!!!
#
# 4. COFF librarian, $(LIBBIN)
#    - POLIB.EXE (PellesC)
#    - LIB.EXE (MS)
#
# 5. COFF Resource compiler, $(RCBIN)
#    - PORC.EXE (PellesC)
#    - RC.EXE (MS)
#
# 6. OMF librarian, $(LIB16BIN) 
#    - WLIB.EXE (Open Watcom)
#    - $(DMCDIR)\LIB.EXE (Digital Mars)
#    - LIB16.EXE (MS, renamed, original name is LIB.EXE)
#
# 7. OMF linker, $(LINK16BIN) 
#    + WLINK.EXE (Open Watcom)
#    + $(DMCDIR)\LINK.EXE (Digital Mars)
#    + LINK16.EXE (MS, renamed, original name is LINK.EXE)
#    + VALX.EXE (LADSoft)
#

# Usually one can select one item of the lists, but
# for the OMF linker this is *not* true!
# LINK16.EXE is required to link HXLdr32.exe and DPMISTxx.BIN,
# and VALX.EXE is required to link HDPMI.

# all tools are available for free, although the licence
# may restrict its usage.

# WSOCK32 is written in C, and requires:
# - open watcom c compiler ($(OWDIR)\binw\wcc386.exe)
# - open watcom linker ($(OWDIR)\binw\wlink.exe)
# - watt-32 library (WATTCPWD.LIB) compiled with open watcom,
#   register calling convention (-3r)

!ifndef DEBUG
DEBUG = 0
!endif

ALL: 
    @cd    HDPMI
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\DPMILDR
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\NTLFNHLP
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\VESA32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\DKRNL32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\DADVAPI
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\DGDI32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\DUSER32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\DDDRAW
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\OLE32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\OLEAUT32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\HXLDR32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\PESTUB
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\HXGUIHLP
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\SB16
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\WINMM
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\DINPUT
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\DSOUND
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\WSOCK32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\WS2_32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\DCIMAN32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\MSACM32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\MPR
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\IPHLPAPI
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\STUBS
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\MZSUPP
    @nmake /nologo DEBUG=$(DEBUG) 
#    @cd ..\NESUPP
#    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\HXHELP
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\PATCHPE
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\PATCHNE
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\SHDPMI
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\SHELL32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\COMCTL32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..\COMDLG32
    @nmake /nologo DEBUG=$(DEBUG) 
    @cd ..

clean: 
    @cd    HDPMI
    @nmake /nologo DEBUG=$(DEBUG) clean
    @cd ..\DPMILDR
    @nmake /nologo DEBUG=$(DEBUG) clean
    @cd ..\NTLFNHLP
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\VESA32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\DKRNL32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\DADVAPI
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\DGDI32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\DUSER32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\DDDRAW
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\OLE32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\OLEAUT32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\HXLDR32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\PESTUB
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\HXGUIHLP
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\SB16
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\WINMM
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\DINPUT
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\DSOUND
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\WSOCK32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\WS2_32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\DCIMAN32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\MSACM32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\MPR
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\IPHLPAPI
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\MZSUPP
    @nmake /nologo DEBUG=$(DEBUG) clean 
#    @cd ..\NESUPP
#    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\STUBS
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\HXHELP
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\PATCHPE
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\PATCHNE
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\SHDPMI
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\SHELL32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\COMCTL32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..\COMDLG32
    @nmake /nologo DEBUG=$(DEBUG) clean 
    @cd ..
