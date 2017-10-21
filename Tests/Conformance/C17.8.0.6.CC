/* Conformance Test 17.8.0.6:  Verification of fscanf, s format code */

#include <stdio.h>

main ()
  {
   FILE  *f1;
   int   i, j;
   char  string [50] = "hey, hey!";


   f1 = fopen ("3/tmp", "wb+");            /* open input file for test */
   if (f1 == NULL)
       goto Fail1;
   fprintf(f1, "   oneLongWord    ten_chars!andMore");
   rewind(f1);

   i  = fscanf (f1, "%*hs");               /* no assignment made; h ignored */
   if (i != 0)
       goto Fail;
   if (strcmp (string, "hey, hey!"))
       goto Fail;

   i = fscanf (f1, "%10ls", string);           /* test assignment to string*/
   if (i != 1)                                 /*   l ignored              */
       goto Fail;
   if (strcmp (string, "ten_chars!"))
       goto Fail;

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.8.0.6\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.6\n");
   return;

Fail1:
   printf ("Unable to open input file for Conformance Test 17.8.0.6\n");
   return;

Fail2:
   printf ("Unable to close input file for Conformance Test 17.8.0.6\n");
   return;
  }
