/* Conformance Test 17.14.0.1:  Verification of ferror and clearerr */

#include <stdio.h>

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


   /* Cause an error to occur. */
   rewind (f);
   i = fread ((void *) buff, sizeof (struct S), 5, f);
   if (i != 3)
       goto Fail;
   i = ferror (f);
   if (i != 0)
       goto Fail;
   i = feof (f);
   if (i == 0)
       goto Fail;

   /* clear the error */
   clearerr (f);
   i = feof (f);
   if (i != 0)
       goto Fail;


   i = fclose (f);                             /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.14.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.14.0.1\n");
   return;

Fail1:
   printf ("Unable to open temp file for Conformance Test 17.14.0.1\n");
   return;

Fail2:
   printf ("Unable to close output file for Conformance Test 17.14.0.1\n");
   return;
  }
