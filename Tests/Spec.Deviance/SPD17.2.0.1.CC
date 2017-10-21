/* Deviance Test 17.2.0.1:  Ensure illegal parameters supplied to fopen */
/*                          are detected                                */

#include <stdio.h>

main ()
  {
   FILE *f1;

   f1 = fopen ("123badfile", "r");         /* try to open file with invalid */
   if (f1 != NULL)                         /*   filename                    */
       goto Fail;

   printf ("Passed Deviance Test 17.2.0.1\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.2.0.1\n");
  }
