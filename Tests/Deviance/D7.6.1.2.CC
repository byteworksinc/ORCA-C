/* Deviance Test 7.6.1.2:  Check for illegal / in a constant expression */

#include <stdio.h>

void main(void)

{
static int i = 4/0;

printf("Failed Deviance Test 7.6.1.2\n");
}
