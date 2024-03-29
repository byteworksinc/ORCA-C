/* Conformance Test 15.7.0.1:  Verification of strstr function */

#include <stddef.h>
#include <string.h>

int printf(const char *, ...);

int main (void)
  {
   char string [] = " this is the source string, a source string";
   char *strPtr;


   strPtr = strstr (string, "source string");
   if (strPtr != (&( (string) [(13)] )) )
       goto Fail;

   strPtr = strstr (string, "source string!");
   if (strPtr != NULL)
       goto Fail;

   printf ("Passed Conformance Test 15.7.0.1\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 15.7.0.1\n");
  }
