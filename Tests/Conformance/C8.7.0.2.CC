/* Conformance Test 8.7.0.2:  Test compact integer switch statement */

#include <stdio.h>

void main(void)

{
int i, sum1 = 0, sum2 = 0;

for (i = 1; i < 11; i++)
   switch (i) {
      case 1: case 3: case 5: case 7: case 9:
         sum1 += i;
         break;
      case 2: case 4: case 6: case 8:
         sum2 += i;
      }

if ((sum1 == 25) && (sum2 == 20))
   printf ("Passed Conformance Test 8.7.0.2\n");
else
   printf ("Failed Conformance Test 8.7.0.2\n");
}
