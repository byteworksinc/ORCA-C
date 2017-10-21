/* Special Conformance Test 17.3.0.3:  Verification of buffering facility */
/*                                     setvbuf: no buffering              */
/*                                                                        */
/* Tester needs to verify that the file 3/tmp is created and contains the */
/* lower case alphabetic characters.                                      */

#include <stdio.h>

main ()
  {
   FILE *f1;                                               /* file pointer */
   int i, j;
   char c;

   f1 = fopen ("3/tmp", "w");                      /* create file to work on */
   if (f1 == NULL)
       goto Fail1;
   i = setvbuf (f1, NULL, _IONBF, 0);      /* allocate write buffer for file */
   if (i)
       goto Fail2;
   for (c = 'a', i = 0; i < 26; i++, c++)  /* write 26 charaters to the file */
     {
       j = fputc (c, f1);
       if (j == EOF)
           goto Fail3;
     }

   i = fclose (f1);                                /* close the file and quit */
   if (i == EOF)
       goto Fail4;

   printf ("Passed Special Conformance Test 17.3.0.3\n");
   return;

Fail1:
   printf ("Could not open tmp file for Special Conformance Test 17.3.0.3\n");
   return;

Fail2:
   printf ("setvbuf command failed in Special Conformance Test 17.3.0.3\n");
   return;

Fail3:
   printf ("Could not write to file for Special Conformance Test 17.3.0.3\n");
   return;

Fail4:
   printf ("Could not close file for Special Conformance Test 17.3.0.3\n");
   return;

  }
