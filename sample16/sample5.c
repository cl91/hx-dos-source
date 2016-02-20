
// sample testing file access working with the OS/2 emulation
// to be compiled with Open Watcom wcc

#include <stdio.h>
#include <malloc.h>
#include <sys\stat.h>
#include <os2.h>

int main(int argc, char * * argv)
{
    FILE * fd;
    char buffer[1024];
    struct stat st;
    int i;

    stat(".\\SAMPLE5.C", &st);

    if (!(fd = fopen(".\\SAMPLE5.C","rb"))) {
        printf("open of SAMPLE5.C failed\n");
        return 1;
    }

    i = fread(buffer, 1, 1024, fd);

    printf("bytes read = %u\n", i);

    fclose(fd);

    return 0;
}
