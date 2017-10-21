/* Conformance Test 17.10.0.1:  Verification of fputs and puts */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int   i,j;
   char  string [255], *strPtr;


   f1 = fopen ("3/tmp", "w+");                 /* open output file for test */
   if (f1 == NULL)
       goto Fail1;

   /* Redirect standard output to a file */

   stdout = freopen ("3/tmp2", "w+", stdout);
   if (stdout == NULL)
       goto Fail3;


   /* Write strings to output files. */

   j = fputs ("this is the first string\n", f1);
   if (j)
       goto Fail;
   j = puts ("and this is the second string");
   if (j)
       goto Fail;


   /* Check files' contents. */

   rewind (f1);
   rewind (stdout);
   strPtr = fgets (string, 100, f1);
   if (strPtr != string)
       goto Fail;
   if (strcmp (string, "this is the first string\n"))
       goto Fail;
   strPtr = fgets (string, 100, stdout);
   if (strPtr != string)
       goto Fail;
   if (strcmp (string, "and this is the second string\n"))
       goto Fail;


   fclose(stdout);                                 /* reset standard out */

   i = fclose (f1);                                /* close the update file */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.10.0.1\n");
   return;

Fail:
   fprintf (stderr, "Failed Conformance Test 17.10.0.1\n");
   return;

Fail1:
   fprintf (stderr, "Unable to open input file for Conformance Test 17.10.0.1\n");
   return;

Fail2:
   fprintf (stderr, "Unable to close input file for Conformance Test 17.10.0.1\n");
   return;

Fail3:
   fprintf (stderr, "Unable to redirect stdout for Conformance Test 17.10.0.1\n");
   return;
  }
