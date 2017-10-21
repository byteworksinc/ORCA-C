/* Conformance Test 8.7.0.4:  Make sure enums are accepted in switch    */

#include <stdio.h>

void main(void)

{
enum color {red, orange, yellow, green, blue, violet} c;
int primary = 0;

for (c = red; c <= violet; c++)
   switch (c) {
      case red: case yellow: case blue:
         primary++;
      }

if (primary == 3)
   printf ("Passed Conformance Test 8.7.0.4\n");
else
   printf ("Failed Conformance Test 8.7.0.4\n");
}
