/* Conformance Test 17.8.0.13:  Verification of sscanf, c format code */

#include <stdio.h>
#include <string.h>

main ()
  {
   char sstr [] = "bten chars!andMore";
   int   i;
   char ch, string [50];


   ch = 'a';                                 /* no assignment should be made */
   i  = sscanf (sstr, "%*hc");               /*   h ignored                  */
   if (i != 0)
       goto Fail;
   if (ch != 'a')
       goto Fail;

   i = sscanf (&sstr [1], "%10lc", string);    /* test assignment to string*/
   if (i != 1)                                 /*   l ignored              */
       goto Fail;
   if (strncmp (string, "ten chars!", 10))
       goto Fail;

   printf ("Passed Conformance Test 17.8.0.13\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.13\n");
   return;
  }
