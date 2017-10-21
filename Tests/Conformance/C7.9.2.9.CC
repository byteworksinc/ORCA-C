/* Conformance Test 7.9.2.9:  Make sure types can be mixed across the    */
/*                            compound assignment operators.             */

#include <stdio.h>
#include <string.h>

main ()

{
int i,j;
char str[] = "How, now, brown cow.";

i = strlen(str);
j = 0;
j += strlen(str);

if (i == j)
   printf ("Passed Conformance Test 7.9.2.9\n");
else
   printf ("Failed Conformance Test 7.9.2.9\n");
}
