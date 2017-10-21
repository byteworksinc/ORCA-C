/* Special Conformance Test 17.3.0.1:  Verification of buffering facility */
/*                                     setvbuf.                           */
/*                                                                        */
/* Tester needs to verify that the file 3/tmp is created and contains the */
/* following characters:  ASCII $20 through $6E, plus ~ and }             */

#include <stdio.h>

main ()
  {
   FILE *f1;                                               /* file pointer */
   char buf [80];                                          /* buffer       */
   int i, j;


   f1 = fopen ("3/tmp", "w");                      /* create file to work on */
   if (f1 == NULL)
       goto Fail1;
   i = setvbuf (f1, buf, _IOFBF, 80);      /* allocate write buffer for file */
   if (i)
       goto Fail2;
   for (i = 0; i < 79; i++)                /* write 79 charaters to the file */
     {
       j = fputc ( (char) (i + 0x20), f1);
       if (j == EOF)
           goto Fail3;
     }

   for (j = 0x20, i = 0; i < 79; i++)               /* check buffer contents */
       if (buf [i] != j++)
           goto Fail;

   j = fputc ('~', f1);                           /* 2 more chars should cause*/
   if (j == EOF)                                  /*   buffer to be flushed   */
       goto Fail3;
   j = fputc ('}', f1);
   if (j == EOF)
       goto Fail3;
   if (buf [0] != '}')
       goto Fail;

   i = fclose (f1);                                /* close the file and quit */
   if (i == EOF)
       goto Fail4;

   printf ("Passed Special Conformance Test 17.3.0.1\n");
   return;

Fail:
   printf ("Failed Special Conformance Test 17.3.0.1\n");
   return;

Fail1:
   printf ("Could not open tmp file for Special Conformance Test 17.3.0.1\n");
   return;

Fail2:
   printf ("Could not allocate buffer for Special Conformance Test 17.3.0.1\n");
   return;

Fail3:
   printf ("Could not write to file for Special Conformance Test 17.3.0.1\n");
   return;

Fail4:
   printf ("Could not close file for Special Conformance Test 17.3.0.1\n");
   return;

  }
