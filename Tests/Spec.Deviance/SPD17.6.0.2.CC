/* Deviance Test 17.6.0.2:  Ensure illegal parameters for getc are detected */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int  i;

   i = getc (f1);                      /* try to read from closed stream */
   if (i != EOF)
       goto Fail;
   if (! (feof (f1)) )
       goto Fail;

   printf ("Passed Deviance Test 17.6.0.2\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.6.0.2\n");
  }
