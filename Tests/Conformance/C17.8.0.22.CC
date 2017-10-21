/* Conformance Test 17.8.0.22:  Verification of scanf, s format code */

#include <stdio.h>

main ()
  {
   int   i, j;
   char  string [50] = "hey, hey!";
   FILE  *f1;


   /* Redirect standard input from a file */

   f1 = fopen ("3/tmp", "wb+");            /* open input file for test */
   if (f1 == NULL)
       goto Fail1;
   fprintf(f1, "   oneLongWord    ten_chars!andMore");
   fclose(f1);

   stdin = freopen ("3/tmp", "r", stdin);
   if (stdin == NULL)
       goto Fail1;

   i  = scanf ("%*hs");                    /* no assignment made; h ignored */
   if (i != 0)
       goto Fail;
   if (strcmp (string, "hey, hey!"))
       goto Fail;

   i = scanf ("%10ls", string);                /* test assignment to string*/
   if (i != 1)                                 /*   l ignored              */
       goto Fail;
   if (strcmp (string, "ten_chars!"))
       goto Fail;

   stdin = freopen (".CONSOLE", "r", stdin);   /* reset stdin and quit */
   if (stdin == NULL)
       goto Fail1;

   printf ("Passed Conformance Test 17.8.0.22\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.22\n");
   return;

Fail1:
   printf ("Unable to redirect stdin for Conformance Test 17.8.0.22\n");
   return;
  }
