/* Deviance Test 17.3.0.3:  Ensure illegal setvbuf calls are detected */

#include <stdio.h>

main ()
  {
   FILE *f1;
   char buf [80];
   int i;

   f1 = fopen ("3/tmp", "w");  /* call setvbuf with an ivalid buffering type */
   if (f1 == NULL)
       goto Fail1;
   i = setvbuf (f1, buf, 3, 80);
   if (!i)
       goto Fail;

   printf ("Passed Deviance Test 17.3.0.3\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.3.0.3\n");
   return;

Fail1:
   printf ("Unable to open work file for Deviance Test 17.3.0.3\n");
   return;
  }
