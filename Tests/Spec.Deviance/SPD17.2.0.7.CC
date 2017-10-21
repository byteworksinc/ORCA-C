/* Deviance Test 17.2.0.7:  Ensure illegal parameters supplied to fopen */
/*                          are detected                                */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int i;

   f1 = fopen ("3/fourthFile", "99");       /* try to open with invalid type */
   if (f1 != NULL)
       goto Fail;

   printf ("Passed Deviance Test 17.2.0.7\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.2.0.7\n");
  }
