 
 1. About

  This directory contains files to make Open Watcom support HX 16bit
  binaries. 
 

 2. Installation

  a) Support for WCC/WLINK

   A file HX16.LNK is supplied which will make OW's WLINK understand
  systems "hx16", "hx16dm" and "hx16mz". Copy this file to the \WATCOM\BINW
  directory, then add the following line to the linker's configuration 
  file \WATCOM\BINW\WLSYSTEM.LNK:
  
    @%watcom%\binw\hx16.lnk
  
  b) Support for WD

   Copy files HX16.TRP, HXHP16.EXE, HXHP16.CFG and RMDBGHLP.BIN to
  \WATCOM\BINW. HXHP16.EXE is a HX NE binary which will require DPMILD16.EXE
  to load, so make sure this file can be found when HXHP16.EXE starts. Then
  using WD for HX 16bit binaries should work, at least on assembly level. But
  the trap file is not restricted to HX binaries, generally it should be able
  to debug real-mode code and 16bit DPMI clients.

  
 3. Creating binaries

   Since OW doesn't support 16bit DOS extended applications (and no CRT is
  supplied for those), the binaries will be linked with OW's 16-bit OS/2
  CRT.

  System     binary format  comment
  ---------------------------------------------------------------------
  hx16       NE (DPMI)      makes the "normal" HX 16-bit binary, which
                            requires HX's NE loader DPMILD16.EXE.
                            Samples: SAMPLE6.MAK
  hx16dm     NE (OS/2)      makes a valid OS/2 16-bit binary which
                            HX's DPMILD16 is able to run in DOS.
                            Samples: SAMPLE2W.MAK, SAMPLE4.MAK
  hx16mz     MZ             is restricted to small memory model.
                            Samples: SAMPLE2MZ.MAK 
  
 
 4. Using WD

  In native DOS to start WD:
  
  enter: WD /tr=HX16 <name of debuggee>
  
  In Windows 9x remote debugging has to be used:
  
  enter in 1. DOS box: winserv /tr=HX16
  enter in 2. DOS box: wd /tr=win <name of debuggee>

  In WinNT/2k/XP remote debugging has to be used as well:

  enter in 1. DOS box: vdmserv /TR=HX16
  enter in 2. DOS box: WD|WDW /TR=VDM sample1.exe  

  To debug graphics applications locally in DOS option /SWAP is required
  as well. For more details please read the OW manuals.

  Japheth
 
