/* Conformance Test 15.3.0.1:  Verification of strcpy, strncpy functions */

#include <stddef.h>
#include <string.h>

main ()
  {
   char s1 [80] = "this is the first string argument";
   char s2 [80] = ", and this is the second string argument!";
   char *strPtr;
   size_t i;

   strPtr = strcpy (s1, s2);
   if (( (i = strlen (strPtr)) != 41 ) || (strPtr != s1))
       goto Fail;
   if (strcmp (s1, ", and this is the second string argument!"))
       goto Fail;

   strcpy(s1, "this is the first string argument");
   strPtr = strncpy (s1, s2, 10);
   if (( (i = strlen (strPtr)) != 33 ) || (strPtr != s1))
       goto Fail;
   if (strcmp (s1, ", and thise first string argument"))
       goto Fail;

   strcpy (s1, ", and thise first string argument");
   strPtr = strncpy (s1, s2, -9L);
   if (( (i = strlen (strPtr)) != 33 ) || (strPtr != s1))
       goto Fail;
   if (strcmp (s1, ", and thise first string argument"))
       goto Fail;


   printf ("Passed Conformance Test 15.3.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 15.3.0.1\n");
  }
