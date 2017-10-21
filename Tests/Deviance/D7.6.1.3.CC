/* Deviance Test 7.6.1.3:  Check for illegal % in a constant expression */

#include <stdio.h>

void main(void)

{
int i;

i = 4%(-1);

printf("Failed Deviance Test 7.6.1.3\n");
}
