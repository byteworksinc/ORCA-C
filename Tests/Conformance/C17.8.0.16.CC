/* Conformance Test 17.8.0.16:  Verification of sscanf, % and [ format codes */

#include <stdio.h>

main ()
  {
   char  sstr [] = "%   these are the ^only[ characters"
                   "*aaabbb a fine mess, you see!  ddddfffffffff";
   int   i;
   char  string [2] [50] = { {"hey, hey!"}, {"you, you"} };


   i  = sscanf (&sstr[0], "%*50h%");    /* no assignment made; * 50 h ignored */
   if (i != 0)
       goto Fail;


   /* Create set of characters which can appear in the output string. */

   i  = sscanf (&sstr [1], "%45[thes aronlyc^[] %*[*ab]", &string [0]);
   if (i != 1)
       goto Fail;
   if (strcmp (&string [0], "   these are the ^only[ characters"))
       goto Fail;


   /* Create set of characters which cannot appear in the output string. */

   i  = sscanf (&sstr [42], "%[^d] %10[df]", &string [0], &string [1]);
   if (i != 2)
       goto Fail;
   if (strcmp (&string [0], " a fine mess, you see!  "))
       goto Fail;
   if (strcmp (&string [1], "ddddffffff"))
       goto Fail;

   printf ("Passed Conformance Test 17.8.0.16\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.16\n");
   return;
  }
