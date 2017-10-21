/* Conformance Test 17.13.0.1:  Verification of fread and fwrite */

#include <stdio.h>
#include <math.h>

struct S { int   i;
           float f;
           char  c; };

main ()
  {
   struct S s [3] = { 1, 1.0, 'a', 2, 2.0, 'b', 3, 3.0, 'c' };
   struct S buff [3];
   FILE   *f = fopen ("3/tmp", "w+b");
   int    i;


   /* Write the elements to the file. */

   if (f == NULL)
       goto Fail1;
   i = fwrite ((void *) s, sizeof (struct S), 3, f);
   if (i != 3)
       goto Fail;


   /* Read the elements from the file. */

   rewind (f);
   i = fread ((void *) buff, sizeof (struct S), 3, f);
   if (i != 3)
       goto Fail;
   if ((s [0].i != 1) || (s [1].i != 2) || (s [2].i != 3))
       goto Fail;
   if ((fabs(s [0].f - 1.0) > 0.00001) || (fabs(s [1].f - 2.0) > 0.00001) ||
       (fabs(s [2].f - 3.0) > 0.00001))
       goto Fail;
   if ((s [0].c != 'a') || (s [1].c != 'b') || (s [2].c != 'c'))
       goto Fail;


   /* Ensure that a count or element_size of 0 causes no chars to be written. */

   i = fwrite ((void *) s, sizeof (struct S), 0, f);
   if (i != 0)
       goto Fail;
   i = fwrite ((void *) s, 0, 2, f);
   if (i != 2)
       goto Fail;
   rewind (f);
   i = fread ((void *) s, sizeof (struct S), 0, f);
   if (i != 0)
       goto Fail;
   i = fread ((void *) s, 0, 2, f);
   if (i != 0)
       goto Fail;


   i = fclose (f);                             /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.13.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.13.0.1\n");
   return;

Fail1:
   printf ("Unable to open temp file for Conformance Test 17.13.0.1\n");
   return;

Fail2:
   printf ("Unable to close output file for Conformance Test 17.13.0.1\n");
   return;
  }
