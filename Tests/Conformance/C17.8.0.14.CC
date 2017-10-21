/* Conformance Test 17.8.0.14:  Verification of sscanf, s format code */

#include <stdio.h>

main ()
  {
   char  sstr [] = "   oneLongWord    ten-chars!andMore";
   int   i, j;
   char  string [50] = "hey, hey!";


   i  = sscanf (&sstr[0], "%*hs");             /* no assignment made; h ignored */
   if (i != 0)
       goto Fail;
   if (strcmp (string, "hey, hey!"))
       goto Fail;

   i = sscanf (&sstr [14], "%10ls", string);   /* test assignment to string*/
   if (i != 1)                                 /*   l ignored              */
       goto Fail;
   if (strcmp (string, "ten-chars!"))
       goto Fail;

   printf ("Passed Conformance Test 17.8.0.14\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.14\n");
   return;
  }
