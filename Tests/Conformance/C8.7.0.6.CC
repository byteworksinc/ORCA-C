/* Conformance Test 8.7.0.6:  Test swicth statements with long          */
/*                            expressions                               */

#include <stdio.h>

void main(void)

{
long l;
int hundreds = 0;

for (l = 0; l < 1000000; l += 10000)
   switch (l) {
      case 100000:
      case 200000:
      case 300000:
      case 400000:
      case 500000:
      case 600000:
      case 700000:
      case 800000:
      case 900000:
         hundreds++;
      }

if (hundreds == 9)
   printf ("Passed Conformance Test 8.7.0.6\n");
else
   printf ("Failed Conformance Test 8.7.0.6\n");
}
