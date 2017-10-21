/* Deviance Test 17.5.0.2:  Ensure illegal parameters passed to ftell */
/*                          are detected                              */

#include <errno.h>
#include <stdio.h>

main ()
  {
   FILE *f1;
   long L1;

   errno = 0;
   L1 = ftell (f1);                       /* try to get current file position */
   if ((L1 != -1L) || (errno == 0))       /*   on unopened stream             */
       goto Fail;

   printf ("Passed Deviance Test 17.5.0.2\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.5.0.2\n");
   return;
  }
