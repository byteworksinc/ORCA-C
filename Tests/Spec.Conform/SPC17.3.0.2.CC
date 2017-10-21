/* Special Conformance Test 17.3.0.2:  Verification of buffering facility */
/*                                     setvbuf using line buffering.      */
/*                                                                        */
/* Tester needs to verify that the file 3/tmp is created and contains the */
/* 2 lines:  all good people are here                                     */
/*           ...and maybe some 'bad' ones, too                            */

#include <stdio.h>
#include <string.h>

main ()
  {
   FILE *f1;                                               /* file pointer */
   char buf [80];                                          /* buffer       */
   int i, j;


   f1 = fopen ("3/tmp", "w");                       /* create file to work on */
   if (f1 == NULL)
       goto Fail1;

   i = setvbuf (f1, buf, _IOLBF, 80);       /* allocate write buffer for file */
   if (i)
       goto Fail2;

   i = fputs ("all good people are here\n", f1);  /* write 1 line to the file */
   if (i)
       goto Fail3;

   if (strncmp (buf, "all good people are here", 24))         /* check buffer */
       goto Fail;                                             /*   contents   */

   i = fputs ("...and maybe some 'bad' ones, too\n", f1);/* write 1 more line */
   if (i)                                                /*   to the file     */
       goto Fail3;

   /* Check buffer contents again */

   if (strncmp (buf, "...and maybe some 'bad' ones, too", 33))
       goto Fail;

   i = fclose (f1);                                /* close the file and quit */
   if (i == EOF)
       goto Fail4;

   printf ("Passed Special Conformance Test 17.3.0.2\n");
   return;

Fail:
   printf ("Failed Special Conformance Test 17.3.0.2\n");
   return;

Fail1:
   printf ("Could not open tmp file for Special Conformance Test 17.3.0.2\n");
   return;

Fail2:
   printf ("Could not allocate buffer for Special Conformance Test 17.3.0.2\n");
   return;

Fail3:
   printf ("Could not write to file for Special Conformance Test 17.3.0.2\n");
   return;

Fail4:
   printf ("Could not close file for Special Conformance Test 17.3.0.2\n");
   return;
  }
