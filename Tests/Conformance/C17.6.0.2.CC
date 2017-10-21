/* Conformance Test 17.6.0.2:  Verification of fgetc, getc, and ungetc with */
/*                             a binary stream                              */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int i, j;
   char ch;


   f1 = fopen ("3/tmp", "w+b");              /* create binary file to work on */
   if (f1 == NULL)
       goto Fail1;
   for (ch = 'a', i = 0; i < 26; i++)
     {
       j = fputc (ch, f1);
       if ((char) j != ch)
           goto Fail2;
       ch++;
     }

   rewind (f1);                            /* check file contents with fgetc */
   ch = 'a';
   while ((i = fgetc (f1)) != EOF)
       if ( (char) i != ch++ )
           goto Fail;
   if (! (feof (f1)) )                     /* ensure end-of-file reached */
       goto Fail;
   j = ungetc (i, f1);                     /* not an error to try to push */
       if (j != EOF)                       /*   back EOF                  */
           goto Fail;

   j = fseek (f1, 0L, SEEK_SET);           /* test getc with temp file    */
   if (j)
       goto Fail3;
   j = ungetc (i, f1);                   /* ungetc should return an error */
       if (j != EOF)                     /*   after seeking on the file   */
           goto Fail;                    /*   before reading              */
   ch = 'a';
   while ((i = getc (f1)) != EOF)
       if ( (char) i != ch++ )
           goto Fail;
   if (! (feof (f1)) )                     /* ensure end-of-file reached */
       goto Fail;
   j = ungetc (i, f1);                     /* not an error to try to push */
       if (j != EOF)                       /*   back EOF                  */
           goto Fail;

   i = fclose (f1);                        /* close the file and quit     */
   if (i == EOF)
       goto Fail4;

   printf ("Passed Conformance Test 17.6.0.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.6.0.2\n");
   return;

Fail1:
   printf ("Unable to open temp file for Conformance Test 17.6.0.2\n");
   return;

Fail2:
   printf ("Unable to write to temp file for Conformance Test 17.6.0.2\n");
   return;

Fail3:
   printf ("Unable to seek to temp file for Conformance Test 17.6.0.2\n");
   return;

Fail4:
   printf ("Unable to close temp file for Conformance Test 17.6.0.2\n");
   return;
  }
