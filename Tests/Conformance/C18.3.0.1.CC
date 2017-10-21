/* Conformance Test 18.3.0.1: Verification of realloc library function */

#include <stddef.h>
#include <stdlib.h>
#include <math.h>

struct S { int i;  extended e; char ch [40]; };

main ()
  {
   struct S *rgn, *ptr1;
   struct S s [3] = { {1, 1.0, "hey"}, {2, 2.0, "you"}, {3, 3.0, "person!"} };


   /* Pass realloc a NULL pointer to initialally allocate some memory. */

   rgn = (struct S *) realloc (NULL, 3 * (sizeof (struct S)) );
   if (rgn == NULL)
       goto Fail1;


   /* Copy the structure array s into the allocated area. */

   memcpy (rgn, s, sizeof (s));


   /* Reallocate a larger area -- ensure initial contents are preserved. */

   rgn = (struct S *) realloc (rgn, 5 * (sizeof (struct S)) );
   if (rgn == NULL)
       goto Fail1;

   ptr1 = rgn;
   if ((ptr1->i != 1) || (fabs(ptr1->e - 1.0) > 0.00001))
       goto Fail;
   if (strcmp (ptr1->ch, "hey"))
       goto Fail;
   ptr1 += 1;

   if ((ptr1->i != 2) || (fabs(ptr1->e - 2.0) > 0.00001))
       goto Fail;
   if (strcmp (ptr1->ch, "you"))
       goto Fail;
   ptr1 += 1;

   if ((ptr1->i != 3) || (fabs(ptr1->e - 3.0) > 0.00001))
       goto Fail;
   if (strcmp (ptr1->ch, "person!"))
       goto Fail;


   /* Ensure passing a size of 0 deallocates the memory. */

   rgn = (struct S *) realloc (rgn, 0);
   if (rgn != NULL)
       goto Fail1;


   printf ("Passed Conformance Test 18.3.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 18.3.0.1\n");
   return;

Fail1:
   printf ("Unable to allocate memory for Conformance Test 18.3.0.1\n");
   return;
  }
