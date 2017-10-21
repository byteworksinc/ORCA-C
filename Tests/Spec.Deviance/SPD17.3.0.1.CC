/* Deviance Test 17.3.0.1:  Ensure illegal setvbuf calls are detected */

#include <stdio.h>

main ()
  {
   FILE *f1;
   char buf [80];
   int i;

   i = setvbuf (f1, buf, _IOLBF, 0);      /* call setvbuf before file opened */
   if (!i)
       goto Fail;

   printf ("Passed Deviance Test 17.3.0.1\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.3.0.1\n");
   return;
  }
