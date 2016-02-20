
#include <stdio.h>

int main(int argc, char * * argv)
{
    printf("hello world\n");
    for (;*argv;argv++)
        printf("arg: %s\n", *argv);
    return 0;
}
