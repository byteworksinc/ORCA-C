/* Deviance Test 17.5.0.1:  Ensure illegal parameters passed to fseek are */
/*                          detected                                      */

#include <errno.h>
#include <stdio.h>

main ()
  {
   FILE *f1;
   int i, j;

   i = fseek (f1, 10L, SEEK_SET);          /* try to seek on unopened stream */
   if (!i)
       goto Fail;
   i = fseek (f1, 10L, SEEK_CUR);
   if (!i)
       goto Fail;
   i = fseek (f1, 10L, SEEK_END);
   if (!i)
       goto Fail;

   printf ("Passed Deviance Test 17.5.0.1\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.5.0.1\n");
  }
