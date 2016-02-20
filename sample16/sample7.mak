
# nmake makefile, creates Sample7.exe, enter:
#    nmake /f sample7.mak
# Borland Pascal 7 is used

NAME=SAMPLE7
PC=bpc.exe 

$(NAME).EXE: $*.PAS $*.MAK
    $(PC) -CP $*.PAS
    ..\Bin\patchNE -r -s $(NAME).EXE


