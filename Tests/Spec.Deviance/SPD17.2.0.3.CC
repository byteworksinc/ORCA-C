/* Deviance Test 17.2.0.3:  Ensure illegal parameters supplied to freopen */
/*                          are detected                                  */

#include <stdio.h>

main ()
  {
   FILE *f1;

   f1 = freopen ("3/thirdFile", "t", f1);    /* try to open with invalid type */
   if (f1 != NULL)
       goto Fail;

   printf ("Passed Deviance Test 17.2.0.3\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.2.0.3\n");
  }
