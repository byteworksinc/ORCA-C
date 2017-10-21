/* Conformance Test 17.16.0.1:  Verification of tmpfile function */

#include <stdio.h>

struct S { int   i;
           float f;
           char  c; };

main ()
  {
   struct S s [3] = { 1, 1.0, 'a', 2, 2.0, 'b', 3, 3.0, 'c' };
   struct S buff [3];
   FILE   *f1, *f2, *f3;
   int    i;


   /* Create 3 temp files and write the elements to the files. */

   f1 = tmpfile ();
   if (f1 == NULL)
       goto Fail1;
   i = fwrite ((void *) s, sizeof (struct S), 3, f1);
   if (i != 3)
       goto Fail;

   f2 = tmpfile ();
   if (f2 == NULL)
       goto Fail1;
   i = fwrite ((void *) s, sizeof (struct S), 3, f2);
   if (i != 3)
       goto Fail;

   f3 = tmpfile ();
   if (f3 == NULL)
       goto Fail1;
   i = fwrite ((void *) s, sizeof (struct S), 3, f3);
   if (i != 3)
       goto Fail;


   /* Read the elements from the files. */

   rewind (f1);
   i = fread ((void *) buff, sizeof (struct S), 3, f1);
   if (i != 3)
       goto Fail;
   if ((s [0].i != 1) || (s [1].i != 2) || (s [2].i != 3))
       goto Fail;
   if ((s [0].f != 1.0) || (s [1].f != 2.0) || (s [2].f != 3.0))
       goto Fail;
   if ((s [0].c != 'a') || (s [1].c != 'b') || (s [2].c != 'c'))
       goto Fail;

   rewind (f2);
   i = fread ((void *) buff, sizeof (struct S), 3, f2);
   if (i != 3)
       goto Fail;
   if ((s [0].i != 1) || (s [1].i != 2) || (s [2].i != 3))
       goto Fail;
   if ((s [0].f != 1.0) || (s [1].f != 2.0) || (s [2].f != 3.0))
       goto Fail;
   if ((s [0].c != 'a') || (s [1].c != 'b') || (s [2].c != 'c'))
       goto Fail;

   rewind (f2);
   i = fread ((void *) buff, sizeof (struct S), 3, f2);
   if (i != 3)
       goto Fail;
   if ((s [0].i != 1) || (s [1].i != 2) || (s [2].i != 3))
       goto Fail;
   if ((s [0].f != 1.0) || (s [1].f != 2.0) || (s [2].f != 3.0))
       goto Fail;
   if ((s [0].c != 'a') || (s [1].c != 'b') || (s [2].c != 'c'))
       goto Fail;


   i = fclose (f1);                            /* close the files and quit */
   if (i == EOF)
       goto Fail2;

   i = fclose (f2);
   if (i == EOF)
       goto Fail2;

   i = fclose (f3);
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.16.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.16.0.1\n");
   return;

Fail1:
   printf ("Unable to open temp file for Conformance Test 17.16.0.1\n");
   return;

Fail2:
   printf ("Unable to close output file for Conformance Test 17.16.0.1\n");
   return;
  }
