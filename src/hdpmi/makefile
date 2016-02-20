
!ifndef DEBUG
DEBUG = 0
!endif

!if $(DEBUG)
SUFFIX=DEB
!else
SUFFIX=REL
!endif

ALL:
    @nmake /nologo /s /f HDPMI32.MAK DEBUG=$(DEBUG) 
    @nmake /nologo /s /f HDPMI16.MAK DEBUG=$(DEBUG) 

clean:
    @nmake /f HDPMI32.MAK clean
    @nmake /f HDPMI16.MAK clean
