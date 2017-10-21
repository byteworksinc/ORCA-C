/* Deviance Test 7.6.1.4:  Check for illegal float / in a constant expression */

#include <stdio.h>

void main(void)

{
float f;

f = 4.0 / 0.0;

printf("Failed Deviance Test 7.6.1.4\n");
}
