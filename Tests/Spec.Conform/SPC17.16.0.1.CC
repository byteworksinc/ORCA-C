/* Special Conformance Test 17.16.0.1:  Verification of tmpnam function */
/*                                                                      */
/* The temporary filenames that the system generates will be displayed. */
/* The tester needs to verify that these files are created after the    */
/* the test is complete.                                                */

#include <string.h>
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

   char filename [3] [L_tmpnam];           /* filename buffers */
   char *namePtr;


   /* Call tmpnam to obtain 3 filenames and display the names to the tester. */

   namePtr = tmpnam (filename [0]);
   if (namePtr == NULL)
       goto Fail;
   if (strcmp (namePtr,filename [0]))
       goto Fail;
   printf ("The first filename is: %s\n", filename [0]);

   namePtr = tmpnam (filename [1]);
   if (namePtr == NULL)
       goto Fail;
   if (strcmp (namePtr, filename [1]))
       goto Fail;
   printf ("The second filename is: %s\n", filename [1]);

   namePtr = tmpnam (NULL);            /* test sending NULL pointer */
   if (namePtr == NULL)
       goto Fail;
   printf ("The third filename is: %s\n", namePtr);
   namePtr = strcpy (filename [2], namePtr);
   if (strcmp (namePtr, filename [2]))
       goto Fail;


   /* Create 3 temp files and write the elements to the files. */

   f1 = fopen (filename [0], "w+b");
   if (f1 == NULL)
       goto Fail1;
   i = fwrite ((void *) s, sizeof (struct S), 3, f1);
   if (i != 3)
       goto Fail;

   f2 = fopen (filename [1], "w+b");
   if (f2 == NULL)
       goto Fail1;
   i = fwrite ((void *) s, sizeof (struct S), 3, f2);
   if (i != 3)
       goto Fail;

   f3 = fopen (filename [2], "w+b");
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

   printf ("Passed Special Conformance Test 17.16.0.1\n");
   return;

Fail:
   printf ("Failed Special Conformance Test 17.16.0.1\n");
   exit (0);

Fail1:
   printf ("Unable to open temp file for Special Conformance Test 17.16.0.1\n");
   exit (0);

Fail2:
   printf ("Unable to close output file for Special Conformance Test 17.16.0.1\n");
   exit (0);
  }
