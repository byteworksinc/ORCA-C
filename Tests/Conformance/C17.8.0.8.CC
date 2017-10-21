/* Conformance Test 17.8.0.8:  Verification of fscanf, % and [ format codes */

#include <stdio.h>

main ()
  {
   FILE  *f1;
   int   i;
   char  string [2] [50] = { {"hey, hey!"}, {"you, you"} };


   f1 = fopen ("3/tmp", "wb+");         /* open input file for test */
   if (f1 == NULL)
       goto Fail1;
   fprintf(f1, "%%   these are the ^only[ characters*aaabbb a fine mess, "
              "you see!  ddddfffffffff");
   rewind(f1);

   i  = fscanf (f1, "%*50h%");         /* no assignment made; * 50 h ignored */
   if (i != 0)
       goto Fail;

   /* Create set of characters which can appear in the output string. */

   i  = fscanf (f1, "%45[thes aronlyc^[h] %*[*ab]", &string [0]);
   if (i != 1)
       goto Fail;
   if (strcmp (&string [0], "   these are the ^only[ characters"))
       goto Fail;

   /* Create set of characters which cannot appear in the output string. */

   i  = fscanf (f1, "%[^d] %10[df]", &string [0], &string [1]);
   if (i != 2)
       goto Fail;
   if (strcmp (&string [0], " a fine mess, you see!  "))
       goto Fail;
   if (strcmp (&string [1], "ddddffffff"))
       goto Fail;

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.8.0.8\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.8\n");
   return;

Fail1:
   printf ("Unable to open input file for Conformance Test 17.8.0.8\n");
   return;

Fail2:
   printf ("Unable to close input file for Conformance Test 17.8.0.8\n");
   return;
  }
