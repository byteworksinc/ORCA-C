/* Deviance Test 17.6.0.3:  Ensure illegal parameters for ungetc are detected */

#include <stdio.h>

FILE *f1;
int  i;

main ()
  {

   i = ungetc ('a', f1);                /* trying to read an unopened stream */
   if (i != EOF)
       goto Fail;
   if (! (feof (f1)) )                 /* ensure error and not just EOF */
       goto Fail;

   printf ("Passed Deviance Test 17.6.0.3\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.6.0.3\n");
  }
