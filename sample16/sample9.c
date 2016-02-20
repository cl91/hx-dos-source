
/* sample dynamically allocates and fills a huge array (128 kB) */

#include <stdio.h>
#include <malloc.h>

int main(int argc, char * * argv)
{
    int huge * hpMem;
    int i;
    printf("trying halloc()\n");
    hpMem = _halloc(0x10000, 2);
    printf("_halloc() returned %lp\n", hpMem);
    for (i = -32768;i < 32767;i++, hpMem++)
        *hpMem = i;
    printf("done filling array\n");
    return 0;
}
