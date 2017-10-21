/* Conformance Test 17.8.0.5:  Verification of fscanf, c format code */

#include <string.h>
#include <stdio.h>

main ()
  {
   FILE *f1;
   int   i;
   char ch, string [50];


   f1 = fopen ("3/tmp", "wb+");            /* open input file for test */
   if (f1 == NULL)
       goto Fail1;
   fprintf(f1, "bten chars!andMore");
   rewind(f1);

   ch = 'a';                               /* no assignment should be made */
   i  = fscanf (f1, "%*hc");               /*   h ignored                  */
   if (i != 0)
       goto Fail;
   if (ch != 'a')
       goto Fail;

   i = fscanf (f1, "%10lc", string);           /* test assignment to string*/
   if (i != 1)                                 /*   l ignored              */
       goto Fail;
   if (strncmp (string, "ten chars!", 10))
       goto Fail;

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.8.0.5\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.5\n");
   return;

Fail1:
   printf ("Unable to open input file for Conformance Test 17.8.0.5\n");
   return;

Fail2:
   printf ("Unable to close input file for Conformance Test 17.8.0.5\n");
   return;
  }
