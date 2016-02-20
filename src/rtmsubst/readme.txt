
 1. About

  Borland C++ and Borland Pascal may be used to create 16-bit DOS protected-
 mode programs. For this purpose a DOS extender, Borland Powerpack, is 
 included in these products, the 16-bit part consisting of RTM.EXE and
 DPMI16BI.OVL. 
  The Borland Extender has some bugs and limitations. That's why it may
 be useful to abandon it. For this reason some 16-bit NE dlls are supplied,
 which are intended to replace RTM.EXE, in conjunction with HX's DPMILD16.EXE.
 
  The Borland Extender is loaded by a DOS MZ stub added to the application
 (16STUB.EXE). This stub will be replaced by HX's DPMIST16.BIN, so there are
 the following changes:
 
 16STUB.EXE                    DPMIST16.BIN
 -----------------------------------------------------
 - loads RTM.EXE               - loads DPMILD16.EXE
 - RTM loads DPMI16BI.OVL      - DPMILD16 loads HDPMI16.EXE
 - app uses exports found in   - app uses exports found in
   + RTM.EXE                     + DPMILD16.EXE
                                 + USER.DLL
                                 + RTM.DLL
                                 
 The stub replacement can be done either during the link step or by tool
 PATCHNE if no link step is possible (Borland Pascal).

 
 2. History
 
 12/02/2006: RTM.ASM added.
             GET/SETCURSORPOS implemented in USER.ASM.
 09/05/2006: USER.ASM added.


 3. License
 
 RTM.ASM and USER.ASM are public domain.


 Japheth

