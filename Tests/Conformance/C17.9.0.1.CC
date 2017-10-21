/* Conformance Test 17.9.0.1:  Verification of fputc, putc, and putchar */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int   i, j;
   char  ch;


   f1 = fopen ("3/tmp", "w+");                 /* open output file for test */
   if (f1 == NULL)
       goto Fail1;

   /* Redirect standard output to a file */

   stdout = freopen ("3/tmp2", "w+", stdout);
   if (stdout == NULL)
       goto Fail3;

   for (ch = 'A', i = 0; i < 26; i++)          /* write uppercase alphabet to */
     {                                         /*   output file               */
       j = fputc (ch, f1);                     /* test fputc */
       if ((j == EOF) || ( ((char) j) != ch ))
           goto Fail;
       j = putc (ch, f1);                      /* test putc  */
       if ((j == EOF) || ( ((char) j) != ch ))
           goto Fail;
       j = putchar (ch);                       /* test putchar */
       if ((j == EOF) || ( ((char) j) != ch ))
           goto Fail;
       ch++;
     }


   /* Check files' contents. */

   rewind (f1);
   rewind (stdout);
   for (ch = 'A', i = 0; i < 26; i++)
     {
       if ( (j = fgetc (f1)) == EOF )
           goto Fail;
       if ( ((char) (j)) != ch )
           goto Fail;
       if ( (j = getc (f1)) == EOF )
           goto Fail;
       if ( ((char) (j)) != ch )
           goto Fail;
       if ( (j = fgetc (stdout)) == EOF )
           goto Fail;
       if ( ((char) (j)) != ch )
           goto Fail;
       ch++;
     }

   fclose(stdout);                                 /* reset standard out */

   i = fclose (f1);                                /* close the update file */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.9.0.1\n");
   return;

Fail:
   fprintf (stderr, "Failed Conformance Test 17.9.0.1\n");
   return;

Fail1:
   fprintf (stderr, "Unable to open input file for Conformance Test 17.9.0.1\n");
   return;

Fail2:
   fprintf (stderr, "Unable to close input file for Conformance Test 17.9.0.1\n");
   return;

Fail3:
   fprintf (stderr, "Unable to redirect stdout for Conformance Test 17.9.0.1\n");
   return;
  }
