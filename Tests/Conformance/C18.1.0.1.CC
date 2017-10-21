/* Conformance Test 18.1.0.1: Verification of calloc library function */

#include <stddef.h>
#include <stdlib.h>

struct S { int i;  extended e; char ch [40]; };

main ()
  {
   char *rgn;
   int  i;

   rgn = (char *) calloc (50, sizeof (struct S));
   if (rgn == NULL)
       goto Fail1;

   for (i = 0; i < 2600; i++)
     {
       if (*rgn != 0)
           goto Fail;
       rgn += 1;
     }

   free (rgn);

   printf ("Passed Conformance Test 18.1.0.1\n");
   return;

Fail:
printf("%u\n", i);
   printf ("Failed Conformance Test 18.1.0.1\n");
   return;

Fail1:
   printf ("Unable to allocate memory for Conformance Test 18.1.0.1\n");
   return;
  }
