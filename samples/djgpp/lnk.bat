@echo off
rem link hello.bin /nologo /subsystem:console /entry:start /out:hello.exe /fixed:no /map:hello.map /opt:nowin98
pestub -q -n -w -x -s hello.exe loadpe.bin
jwlink format windows pe hx f hello.bin name hello.exe sort global op start=start, m, stub=loadpe.bin segment type code writable
