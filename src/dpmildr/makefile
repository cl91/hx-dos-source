
!ifndef DEBUG
DEBUG = 0
!endif

ALL:
    @nmake /nologo /f DPMILD32.MAK DEBUG=$(DEBUG) 
    @nmake /nologo /f DPMILD16.MAK DEBUG=$(DEBUG) 

clean:
    @nmake /nologo /f DPMILD32.MAK DEBUG=$(DEBUG) clean
    @nmake /nologo /f DPMILD16.MAK DEBUG=$(DEBUG) clean
