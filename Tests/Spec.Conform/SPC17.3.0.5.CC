/*                                                                        */
/* Special Conformance Test 17.3.0.5:  Verification of buffering facility */
/*                                     setbuf.                            */
/*                                                                        */
/* Tester needs to verify that the file 3/tmp is created and contains the */
/* 26 uppercase alphabetic characters.                                    */
/*                                                                        */

#include <stdio.h>

main ()
  {
   FILE *f1;                                               /* file pointer */
   int i, j;
   char ch;

   f1 = fopen ("3/tmp", "w");                      /* create file to work on */
   if (f1 == NULL)
       goto Fail1;
   setbuf (f1, NULL);                       /* specify no buffering for file */
                                            /*  just hope it works           */
   for (ch = 'A', i = 0; i < 26; ch++, i++)    /* write 79 chars to the file */
     {
       j = fputc (ch, f1);
       if (j == EOF)
           goto Fail2;
     }

   i = fclose (f1);                                /* close the file and quit */
   if (i == EOF)
       goto Fail3;

   printf ("Passed Special Conformance Test 17.3.0.5\n");
   return;

Fail:
   printf ("Failed Special Conformance Test 17.3.0.5\n");
   return;

Fail1:
   printf ("Could not open tmp file for Special Conformance Test 17.3.0.5\n");
   return;

Fail2:
   printf ("Could not write to file for Special Conformance Test 17.3.0.5\n");
   return;

Fail3:
   printf ("Could not close file for Special Conformance Test 17.3.0.5\n");
   return;

  }
