/* Conformance Test 17.8.0.24:  Verification of scanf, % and [ format codes */

#include <stdio.h>

main ()
  {
   int   i;
   char  string [2] [50] = { {"hey, hey!"}, {"you, you"} };
   FILE  *f1;


   /* Redirect standard input from a file */

   f1 = fopen ("3/tmp", "wb+");         /* open input file for test */
   if (f1 == NULL)
       goto Fail1;
   fprintf(f1, "%%   these are the ^only[ characters*aaabbb a fine mess, "
              "you see!  ddddfffffffff");
   fclose(f1);

   stdin = freopen ("3/tmp", "r", stdin);
   if (stdin == NULL)
       goto Fail1;

   i  = scanf ("%*50h%");         /* no assignment made; * 50 h ignored */
   if (i != 0)
       goto Fail;

   /* Create set of characters which can appear in the output string. */

   i  = scanf ("%45[thes arohnlyc^[] %*[*ab]", &string [0]);
   if (i != 1)
       goto Fail;
   if (strcmp (&string [0], "   these are the ^only[ characters"))
       goto Fail;

   /* Create set of characters which cannot appear in the output string. */

   i  = scanf ("%[^d] %10[df]", &string [0], &string [1]);
   if (i != 2)
       goto Fail;
   if (strcmp (&string [0], " a fine mess, you see!  "))
       goto Fail;
   if (strcmp (&string [1], "ddddffffff"))
       goto Fail;

   stdin = freopen (".CONSOLE", "r", stdin);   /* reset stdin and quit */
   if (stdin == NULL)
       goto Fail1;

   printf ("Passed Conformance Test 17.8.0.24\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.24\n");
   return;

Fail1:
   printf ("Unable to open input file for Conformance Test 17.8.0.24\n");
   return;
  }
