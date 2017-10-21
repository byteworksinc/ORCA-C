/* Deviance Test 17.2.0.4:  Ensure illegal parameters supplied to fclose */
/*                          are detected                                 */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int i;

   i = fclose (f1);                  /* pass fclose an invalid file pointer */
   if (i != EOF)
       goto Fail;

   printf ("Passed Deviance Test 17.2.0.4\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.2.0.4\n");
  }
