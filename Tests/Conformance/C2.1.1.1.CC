/* Conformance Test 2.1.1.1:  Verification of encoding for null */
#include <string.h>

main ()
  {
   char string [4];

   strcpy (string, "");
   if (string [0] != 0)
       goto Fail;

   strcpy (string, "abc");
   if (string [3] != 0)
       goto Fail;

   printf ("Passed Conformance Test 2.1.1.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.1.1.1\n");
 }
