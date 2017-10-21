/* Conformance Test 17.6.0.1:  Verification of fgetc, getc, and ungetc with */
/*                             a text stream                                */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int i, j;
   char ch;


   f1 = fopen ("3/tmp", "w+");                 /* create text file to work on */
   if (f1 == NULL)
       goto Fail1;
   for (ch = 'a', i = 0; i < 26; i++)
     {
       j = fputc (ch, f1);
       if ((char) j != ch)
           goto Fail2;
       ch++;
     }
   j = fputc ('\r', f1);                   /* text files end with return */
   if (j != '\r')
       goto Fail2;

   rewind (f1);                            /* check file contents with fgetc */
   for (ch = 'a', i = 0; i < 26; i++)
     {
       j = fgetc (f1);
       if ( (char) j != ch++ )
           goto Fail;
     }

   i = ungetc ('F', f1);                   /* test ungetc */
   if (i != 'F')
       goto Fail;
   i = fgetc (f1);
   if (i != 'F')
       goto Fail;

   i = fgetc (f1);
   if (i != '\n')
       goto Fail;
   i = fgetc (f1);
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
   for (ch = 'a', i = 0; i < 26; i++)
     {
       j = getc (f1);
       if ( (char) j != ch++ )
           goto Fail;
     }

   i = ungetc ('L', f1);                   /* test ungetc */
   if (i != 'L')
       goto Fail;
   i = fgetc (f1);
   if (i != 'L')
       goto Fail;

   i = getc (f1);
   if (i != '\n')
       goto Fail;
   i = getc (f1);
   if (! (feof (f1)) )                     /* ensure end-of-file reached */
       goto Fail;
   j = ungetc (i, f1);                     /* not an error to try to push */
       if (j != EOF)                       /*   back EOF                  */
           goto Fail;

   i = fclose (f1);                        /* close the file and quit     */
   if (i == EOF)
       goto Fail4;

   printf ("Passed Conformance Test 17.6.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.6.0.1\n");
   return;

Fail1:
   printf ("Unable to open temp file for Conformance Test 17.6.0.1\n");
   return;

Fail2:
   printf ("Unable to write to temp file for Conformance Test 17.6.0.1\n");
   return;

Fail3:
   printf ("Unable to seek to temp file for Conformance Test 17.6.0.1\n");
   return;

Fail4:
   printf ("Unable to close temp file for Conformance Test 17.6.0.1\n");
   return;
  }
