/* Deviance Test 17.2.0.2:  Ensure illegal parameters supplied to freopen */
/*                          are detected                                  */

#include <stdio.h>

main ()
  {
   FILE *f1;

   f1 = freopen ("123badfile", "r", f1);   /* invalid stream to freopen */
   if (f1 != NULL)
       goto Fail;

   printf ("Passed Deviance Test 17.2.0.2\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.2.0.2\n");
  }
