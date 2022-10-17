/* Conformance Test 2.7.4.2:  Ensure ability to define string constants */
/*                            across source lines                       */

#include <string.h>

int printf(const char *, ...);

int main (void)
  {
   char s[300] = "The string begins here...\
                  and ends here!";

   if (strcmp (s, "The string begins here...                  and ends here!"))
       goto Fail;

   strcpy (s, "another spl\
   it string!");
   if (strcmp (s, "another spl   it string!"))
       goto Fail;

   printf ("Passed Conformance Test 2.7.4.2\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 2.7.4.2\n");
  }
