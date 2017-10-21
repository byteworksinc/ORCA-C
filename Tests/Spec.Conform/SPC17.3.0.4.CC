/* Special Conformance Test 17.3.0.4:  Verification of buffering facility */
/*                                     setbuf.                            */
/*                                                                        */
/* Tester needs to verify that the file 3/tmp is created and contains the */
/* following characters:  ASCII $20 through $6E, plus ~ and }             */

#include <stdio.h>
static char buf [BUFSIZ];

main ()
  {
   int count = 0;
   FILE *f1;                                               /* file pointer */
   char ch;
   int i, j;
   long L;

   count++;
   f1 = fopen ("3/tmp", "w");                      /* create file to work on */
   if (f1 == NULL)
       goto Fail1;
   setbuf (f1, buf);                       /* allocate write buffer for file */
                                           /*   just hope it works           */
   for (ch = ' ', i = 0; i < 30; ch++, i++)    /* write 30 chars to the file */
     {
       j = fputc (ch, f1);
       if (j == EOF)
           goto Fail2;
     }

   for (j = 0x20, i = 0; i < 30; i++)               /* check buffer contents */
       if (buf [i] != j++)
           goto Fail;

   count++;
   for (L = 30; L < BUFSIZ; L++)                 /* fill buffer so that it'll */
     {                                           /*    be flushed             */
       j = fputc ('a', f1);
       if (j == EOF)
           goto Fail2;
     }

   j = fputc ('~', f1);                           /* write 1 more char to buf */
   if (j == EOF)                                  /*   & then check contents  */
       goto Fail2;
   if (buf [0] != '~')
       goto Fail;

   i = fclose (f1);                                /* close the file and quit */
   if (i == EOF)
       goto Fail3;

   printf ("Passed Special Conformance Test 17.3.0.4\n");
   return;

Fail:
   printf ("Failed Special Conformance Test 17.3.0.4: count = %d\n", count);
   return;

Fail1:
   printf ("Could not open tmp file for Special Conformance Test 17.3.0.4\n");
   return;

Fail2:
   printf ("Could not write to file for Special Conformance Test 17.3.0.4\n");
   return;

Fail3:
   printf ("Could not close file for Special Conformance Test 17.3.0.4\n");
   return;

  }
