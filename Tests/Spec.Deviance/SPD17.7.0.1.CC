/* Deviance Test 17.7.0.1:  Ensure illegal parameters for fgets are detected */

#include <stdio.h>

FILE *f1;
char string [80], *s;
int  i;

main ()
  {

   s = fgets (string, 90, f1);         /* trying to read an unopened stream */
   if (s != NULL)
       goto Fail;
   if (! (feof (f1)) )                 /* ensure error and not just EOF */
       goto Fail;

   printf ("Passed Deviance Test 17.7.0.1\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.7.0.1\n");
  }
