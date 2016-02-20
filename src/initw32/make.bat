@echo off
rem
rem InitW32
rem
jwasm.exe -nologo -c -coff -D?FLAT=1 -D?CLEARHIGHEBP=0 -I..\..\Include INITW32.ASM
copy INITW32.OBJ ..\..\Lib
copy INITW32.OBJ \lib\coff
rem
jwasm.exe -nologo -c -D?FLAT=1 -D?CLEARHIGHEBP=0 -I..\..\Include INITW32.ASM
copy INITW32.OBJ \lib\omf
rem
rem InitW32x
rem
jwasm.exe -nologo -c -coff -D?FLAT=1 -D?CLEARHIGHEBP=0 -I..\..\Include INITW32X.ASM
copy INITW32x.OBJ ..\..\Lib
copy INITW32x.OBJ \lib\coff
rem
jwasm.exe -nologo -c -D?FLAT=1 -D?CLEARHIGHEBP=0 -I..\..\Include INITW32X.ASM
copy INITW32x.OBJ \lib\omf
rem
rem GetModH (for MS VC++ Toolkit 2003
rem
jwasm.exe -nologo -c -coff -I..\..\Include GETMODH.ASM
copy GETMODH.OBJ ..\..\Lib
copy INITW32.OBJ \lib\coff
