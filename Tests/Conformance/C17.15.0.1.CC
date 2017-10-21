/* Conformance Test 17.15.0.1:  Verification of remove and rename */

#include <stdio.h>

struct S { int   i;
           float f;
           char  c; };

main ()
  {
   struct S s [3] = { 1, 1.0, 'a', 2, 2.0, 'b', 3, 3.0, 'c' };
   struct S buff [3];
   FILE   *f = fopen ("3/tmp", "wb");
   int    i;


   /* Write the elements to the file. */

   if (f == NULL)
       goto Fail1;
   i = fwrite ((void *) s, sizeof (struct S), 3, f);
   if (i != 3)
       goto Fail;

   i = fclose (f);                             /* close the file */
   if (i == EOF)
       goto Fail2;


   /* Rename and then delete the file. */

   i = remove ("3/temp");
   i = rename ("3/tmp", "3/temp");
   if (i)
       goto Fail;
   i = remove ("3/temp");
   if (i)
       goto Fail;

   printf ("Passed Conformance Test 17.15.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.15.0.1\n");
   return;

Fail1:
   printf ("Unable to open temp file for Conformance Test 17.15.0.1\n");
   return;

Fail2:
   printf ("Unable to close output file for Conformance Test 17.15.0.1\n");
   return;
  }
