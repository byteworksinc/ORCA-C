/* Conformance Test 8.7.0.3:  Make sure negative numbers are accepted   */
/*                            in switch                                 */

#include <stdio.h>

void main(void)

{
int i, sum1 = 0, sum2 = 0;

for (i = -11; i < 0; i++)
   switch (i) {
      case -1: case -3: case -5: case -7: case -9:
         sum1 += i;
         break;
      case -2: case -4: case -6: case -8:
         sum2 += i;
      }

if ((sum1 == -25) && (sum2 == -20))
   printf ("Passed Conformance Test 8.7.0.3\n");
else
   printf ("Failed Conformance Test 8.7.0.3\n");
}
