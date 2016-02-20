
List of HX main parts, their size and tools required to build the binary:

         lines     total  asm/c  linker  lib   rc
----------------------------------------------------
HDPMI    25000            m/jw   jwlink  wlib
DPMILDR  13500            m/jw   wlink
STUBS     1000            jw     -
DKRNL32  35000            m/jw   mslink  wlib
DADVAPI   2000            m/jw   mslink  wlib
DGDI      8000            m/jw   mslink  wlib
DUSER32   9000            m/jw   mslink  wlib  wrc
DDDRAW    3600            m/jw   mslink  wlib
OLE32      600            m/jw   mslink  wlib
OLEAUT32   600            m/jw   mslink  wlib
VESA32    3000            m/jw   mslink  wlib
HXLDR32    950            jw     wlink
PESTUB     900    103150  m/jw   wlink

HXGUIHLP  1000            m/jw   mslink
DINPUT    1500            m/jw   mslink  wlib
DSOUND    1200            m/jw   mslink  wlib
SB16      1500            m/jw   mslink  wlib
SHELL32    500            m/jw   mslink  wlib
WINMM     2600            m/jw   mslink  wlib
WSOCK32   1050      9350  wcc386 wlink

MZSUPP    1150            m/jw   -       wlib
PATCHPE    300            jw     -
PATCHNE    500            jw     -
HXHELP    6900      8850  m/jw   wlink
----------------------------------------------------
                  121350
