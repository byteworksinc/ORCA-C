/* Deviance Test 17.3.0.2:  Ensure illegal setvbuf calls are detected */

#include <stdio.h>

main ()
  {
   FILE *f1;
   char buf [80];
   int i;

   f1 = fopen ("3/tmp", "w");          /* call setvbuf after I/O already done */
   if (f1 == NULL)
       goto Fail1;
   i = fputc ('a', f1);                      /* write a character to the file */
   if (i == EOF)
       goto Fail2;
   i = setvbuf (f1, NULL, _IONBF, 0);
   if (!i)
       goto Fail;

   printf ("Passed Deviance Test 17.3.0.2\n");
   return;

Fail:
   printf ("Failed Deviance Test 17.3.0.2\n");
   return;

Fail1:
   printf ("Unable to open work file for Deviance Test 17.3.0.2\n");
   return;

Fail2:
   printf ("Unable to write to file for Deviance Test 17.3.0.2\n");
   return;
  }
