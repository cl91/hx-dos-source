
// sample testing spawn() working with the OS/2 emulation
// to be compiled with Open Watcom wcc

// currently spawn() won't work since the OW rtl uses functions
// not emulated. Instead the native OS/2 call DosExecPgm() is used.

#include <stdio.h>
#include <process.h>
#include <os2.h>

int main(int argc, char * * argv)
{
    int i;
    RESULTCODES result;

    // launch first program

    printf("launching sample5.exe\n");
    fflush(stdout); /* ensure it *is* displayed */
#if 0
    spawnv(P_WAIT, ".\\SAMPLE5.EXE", "");
#else
    if (DosExecPgm(0,0,0,0,0,&result,".\\SAMPLE5.EXE") == 0)
#endif
        printf("back in sample6.exe, returncode=%X\n", result.codeResult);
    else
        printf("launch failed\n");

    // launch second program

    printf("launching sample2w.exe\n");
    fflush(stdout); /* ensure it *is* displayed */
#if 0
    spawnv(P_WAIT, ".\\SAMPLE2W.EXE", "");
#else
    if (DosExecPgm(0,0,0,0,0,&result,".\\SAMPLE2W.EXE") == 0)
#endif
        printf("back in sample6.exe, returncode=%X\n", result.codeResult);
    else
        printf("launch failed\n");

    return 0;
}
