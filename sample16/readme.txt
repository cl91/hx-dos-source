 
 1. About

  This directory contains some 16-bit sample programs. The HX DOS extender
 supports such binaries in 2 file formats, NE and MZ. For both formats, if
 no DPMI server is found, the startup code will try to load HDPMI16.EXE.

 For NE format, the standard stub DPMIST16.BIN will search the NE loader
 DPMILD16.EXE in the directories contained in PATH. Alternatively one
 can link NE binaries with stub DPMILD16.BIN. This indeed IS the NE loader
 as a MZ stub, thus it doesn't need to be searched, but OTOH this stub
 increases the binary size by about 14 kb.

 To prepare Open Watcom to be used with HX please read OWSUPP16\Readme.txt
 and follow the instructions to install HX's OW support for 16bit.
 
 Please note that most makefiles supplied are in NMAKE format. Using 
 Borland's MAKE.EXE or Open Watcom's WMAKE.EXE may require some adjustments.
 

 2. OS/2 Emulation
 
 To support creating 16-bit HX binaries with Open Watcom an OS/2
 emulation layer has to be used. That's because this environment doesn't
 support any 16-bit DOS extender, and therefore the Open Watcom 
 OS/2 C runtime libraries is the only option which remains. These
 libraries make some OS/2 calls and the called API has to be emulated.
 There are two approaches:
 
 - use DOSXXXS.LIB (the only possible option for HX MZ format). This
   will make the linker to include the OS/2 emulation code statically.
   
 - use DOSXXX.LIB in the link step. To run the binary in DOS, some or all
   of the following 16-bit dlls are required (located in HX\BIN):
 
   + DOSCALLS.DLL
   + KBDCALLS.DLL
   + VIOCALLS.DLL
   + NLS.DLL
   
   This might be seen as a disadvantage and in most cases it is. But thus
   the app can be linked as native OS/2 application and might run better
   in this environment.


 3. Debugging
 
 a). Using Open Watcom Debugger WD

  Read OWSUPP16\Readme.txt how to install WD support for HX 16 bit
 binaries and how to use the debugger. Newer versions of WD should 
 understand the Codeview format, so debugging on source code level may
 work for binaries created with MS tools (MASM, VC) as well.

  
 b). Using TD Debugger

  Borland's debugger TD may be a better choice for debugging if TASM or
 the Borland C++ compiler are to be used. However, there is a security check
 in TD which prevents it from loading HX binaries. That's why one has to
 tell the linker in the .DEF file to use Borland's 16stub.exe. With this stub 
 included the binary in fact is a powerpack application and will require
 rtm.exe and dpmi16bi.ovl to run! Since powerpack has some limitations which
 HX has not, it should be used for debugging purposes only.


 c). Debugging with DEB16F
 
  This 16-bit debugger is written mainly for HX and should be able
 to debug any binary without modifications. DEB16F has a line oriented
 user interface and doesn't understand debugging on source code level.
 It may be downloaded from http://www.japheth.de/Download/deb16f.zip.
 Unlike the other debuggers mentioned above DEB16F supports mixed-mode
 debugging.

 d). Others
 
 - LadSoft's GRDB knows how to handle DPMI clients.
 - The FreeDOS version of DEBUG might understand to debug DPMI applications
   (must be v1.02 or higher).


 4. Samples
 
 NE file format samples:
 
 - Sample1.ASM: a simple hello world app written in Assembler. No external
   libraries are required for the link step. To create the binary use one of
   the following makefiles:
   + Sample1m.mak, will use MS MASM and LINK
   + Sample1b.mak, will use Borland's TASM and TLINK
   + Sample1w.mak, will use Open Watcom's WASM and WLINK
 
 - Sample2.C: a simple hello world app written in C. Either the C runtime
   for the small or the large memory model is used. To create the binary use
   one of the following makefiles:
   + Sample2m.mak, will use MS VC 1.5 to compile and link
   + Sample2b.mak, will use Borland C++ (large model)
   + Sample2d.mak, will use Digital Mars C++ (small model)
   + Sample2w.mak, will use Open Watcom to compile and link
   + Sample2l.mak: will use MS VC 1.5 to compile and link (large model)
   
 - Sample3.CBL: a simple hello world app written in MS Cobol. The makefile
   sample3.mak will create the binary. 

 - Sample4.C: shows some memory allocation methods for 16-bit dpmi clients.
   Built with Open Watcom using small memory model, linked as OS/2 16-bit
   application.

 - Sample5.C: tests some C file functions of the OS/2 emulation. Built with
   Open Watcom using small memory model, linked as OS/2 16-bit application.

 - Sample6.C: sample for Open Watcom how to start another process.
   
 - Sample7.PAS: sample how to make a HX binary with Borland Pascal.

 - Sample8.ASM: a 16-bit OS/2 "hello world" for MASM. It's linked without
   HX's DPMIST16.BIN, therefore to run it in DOS enter "DPMILD16 Sample8".

 - Sample9.C: shows how to alloc and fill a huge array.


 MZ file format samples:
 
 - Smpl1mz.MAK: this will create Smpl1MZ.EXE, a simple hello world app
   written in Assember (MASM, TASM or WASM). No external libraries are
   required. 

 - Smpl2mzm.MAK: this will create Smpl2MZm.EXE from Sample2.C using
   MS Visual C++ 1.5. Small memory model is used, others are not supported.
   
 - Smpl2mzw.MAK: this will create Smpl2MZw.EXE from Sample2.C using
   Open Watcom's WCC and WLINK. Small memory model is used, others are
   not supported.

 - Smpl2mzd.MAK: this will create Smpl2MZd.EXE from Sample2.C using
   Digital Mars C++. Small memory model is used, others are not supported.
   Since no 16bit protected mode CRT is supplied with DM, the MS VC
   library SLIBCEW.LIB is used instead.


 Japheth
 
