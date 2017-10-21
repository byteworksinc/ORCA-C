/* Conformance Test 17.8.0.21:  Verification of scanf, c format code */

#include <string.h>
#include <stdio.h>

main ()
  {
   FILE *f1;
   int   i;
   char ch, string [50];


   /* Redirect standard input from a file */

   f1 = fopen ("3/tmp", "wb+");            /* open input file for test */
   if (f1 == NULL)
       goto Fail1;
   fprintf(f1, "bten chars!andMore");
   fclose(f1);

   stdin = freopen ("3/tmp", "r", stdin);
   if (stdin == NULL)
       goto Fail1;

   ch = 'a';                               /* no assignment should be made */
   i  = scanf ("%*hc");                    /*   h ignored                  */
   if (i != 0)
       goto Fail;
   if (ch != 'a')
       goto Fail;

   i = scanf ("%10lc", string);           /* test assignment to string*/
   if (i != 1)                            /*   l ignored              */
       goto Fail;
   if (strncmp (string, "ten chars!", 10))
       goto Fail;

   stdin = freopen (".CONSOLE", "r", stdin);   /* reset stdin and quit */
   if (stdin == NULL)
       goto Fail1;

   printf ("Passed Conformance Test 17.8.0.21\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.21\n");
   return;

Fail1:
   printf ("Unable to redirect stdin for Conformance Test 17.8.0.21\n");
   return;
  }
