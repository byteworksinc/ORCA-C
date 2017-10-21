/* Conformance Test 15.2.0.1:  Verification of strcmp, strncmp functions */

#include <string.h>

main ()
  {
   int i;

   char s1 [] = "this is a string argument ";
   char s2 [] = "this is a string argument!";
   char s3 [160] = "";


   i = strcmp (s1, s2);                /* ensure strcmp reports s1 < s2 */
   if (i >= 0)
       goto Fail;

   i = strcmp (s2, s1);
   if (i <= 0)
       goto Fail;

   i = strncmp (s1, s2, 100);          /* should compare all chars */
   if (i >= 0)
       goto Fail;

   i = strncmp (s1, s2, 25);           /* should compare 1st 25 chars */
   if (i != 0)
       goto Fail;

   i = strncmp (s1, s2, -90L);         /* should just return 0 */
   if (i != 0)
       goto Fail;

   printf ("Passed Conformance Test 15.2.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 15.2.0.1\n");
  }
