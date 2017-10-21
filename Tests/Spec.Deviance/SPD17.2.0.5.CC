/* Deviance Test 17.2.0.5:  Ensure illegal parameters supplied to fflush */
/*                          are detected                                 */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int i;

   i = fflush (f1);                  /* pass fflush an invalid file pointer */
   if (i != EOF)
       goto Fail;

   printf ("Passed Deviance Test 17.2.0.5\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.2.0.5\n");
  }
