/* Deviance Test 17.6.0.1:  Ensure illegal parameters for fgetc are detected */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int  i;

   i = fgetc (f1);                     /* trying to read an unopened stream */
   if (i != EOF)
       goto Fail;
   if (! (feof (f1)) )                 /* ensure error and not just EOF */
       goto Fail;

   printf ("Passed Deviance Test 17.6.0.1\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.6.0.1\n");
  }
