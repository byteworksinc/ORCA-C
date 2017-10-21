/* Conformance Test 8.7.0.5:  Test sparse switch statements             */

#include <stdio.h>

void main(void)

{
int i, hundreds = 0;

for (i = 0; i < 1000; i += 10)
   switch (i) {
      case 100:
      case 200:
      case 300:
      case 400:
      case 500:
      case 600:
      case 700:
      case 800:
      case 900:
         hundreds++;
      }

if (hundreds == 9)
   printf ("Passed Conformance Test 8.7.0.5\n");
else
   printf ("Failed Conformance Test 8.7.0.5\n");
}
