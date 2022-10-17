/* Conformance Test 18.1.0.1: Verification of calloc library function */

#include <stddef.h>
#include <stdlib.h>

int printf(const char *, ...);

struct S { int i;  extended e; char ch [40]; };

int main (void)
  {
   char *rgn, *ptr1;
   int  i;

   rgn = (char *) calloc (50, sizeof (struct S));
   if (rgn == NULL)
       goto Fail1;
   ptr1 = rgn;

   for (i = 0; i < 2600; i++)
     {
       if (*rgn != 0)
           goto Fail;
       rgn += 1;
     }

   free (ptr1);

   printf ("Passed Conformance Test 18.1.0.1\n");
   return 0;

Fail:
printf("%u\n", i);
   printf ("Failed Conformance Test 18.1.0.1\n");
   return 0;

Fail1:
   printf ("Unable to allocate memory for Conformance Test 18.1.0.1\n");
   return 0;
  }
