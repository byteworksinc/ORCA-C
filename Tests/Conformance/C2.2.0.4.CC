/* Conformance test 2.2.0.4:  Comment characters in strings */

#include <string.h>

int printf(const char *, ...);

int main (void)
  {
   if (strlen("/*") == 2)
       printf ("Passed Conformance Test 2.2.0.4\n");
   else
       printf ("Failed Conformance Test 2.2.0.4\n");
   }
