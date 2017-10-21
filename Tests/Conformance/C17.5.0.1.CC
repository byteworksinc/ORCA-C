/* Conformance Test 17.5.0.1:  Verification of fseek function */

#include <stdio.h>

main ()
  {
   FILE *f1;                           /* file pointer */
   int i, j, k, m;

   f1 = fopen ("3/tmp", "w+b");        /* create binary file to work on */
   if (f1 == NULL)
       goto Fail1;
   for (i = 0; i < 100; i++)           /* write 100 integers to the file */
     {
       j = fprintf (f1, "%2d  ", i);
       if (j == EOF)
           goto Fail2;
     }

   i = fseek (f1, 50, SEEK_END);       /* extend file by extra 50 bytes */
   if (i)
       goto Fail;
   rewind (f1);                        /* position at beginning of file */
   i = 0;
   while ((j = fgetc (f1)) != EOF)
       i += 1;
   if (! (j = feof (f1)) )
       goto Fail3;
   if (i != 450)                       /* check size of file in bytes */
       goto Fail;

   /* Test seek from beginning of file. */

   for (k = 0, i = 0; i < 100; i++)
     {
       j = fseek (f1, k, SEEK_SET);
       if (j)
           goto Fail;
       j = fscanf (f1, "%d", &m);
       if (j == EOF)
           goto Fail3;
       if (m != i)
           goto Fail;
       k += 4;
     }

   /* Test seek from end of file. */

   j = fseek (f1, -54, SEEK_END);          /* start 54 bytes from end of file */
   if (j)
       goto Fail;
   for (k = -54, i = 99; i > 0; i--)
     {
       j = fscanf (f1, "%d", &m);
       if (j == EOF)
           goto Fail3;
       if (m != i)
           goto Fail;
       k -= 4;
       j = fseek (f1, k, SEEK_END);
       if (j)
           goto Fail;
     }

   /* Test seek from current position in file. */
   j = fseek (f1, 12, SEEK_CUR);
   if (j)
       goto Fail;
   j = fscanf (f1, "%d", &m);
   if (j == EOF)
       goto Fail3;
   if (m != 3)
       goto Fail;

   j = fseek (f1, 12, SEEK_CUR);
   if (j)
       goto Fail;
   j = fscanf (f1, "%d", &m);
   if (j == EOF)
       goto Fail3;
   if (m != 7)
       goto Fail;

   /* Close the file and quit. */

   j = fclose (f1);
   if (j == EOF)
       goto Fail4;

   printf ("Passed Conformance Test 17.5.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.5.0.1\n");
   return;

Fail1:
   printf ("Could not open tmp file for Conformance Test 17.5.0.1\n");
   return;

Fail2:
   printf ("Could not write to file for Conformance Test 17.5.0.1\n");
   return;

Fail3:
   printf ("Error while reading file for Conformance Test 17.5.0.1\n");
   return;

Fail4:
   printf ("Could not close file for Conformance Test 17.5.0.1\n");
   return;
  }
