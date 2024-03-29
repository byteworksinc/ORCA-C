/* Conformance Test 2.1.1.2:  Verification of newline character */

#include <string.h>

int printf(const char *, ...);

int main (void)
  {
   char string [10];

   strcpy (string, "\n");
   if (string [0] != 0x0A)
       goto Fail;

   strcpy (string, "abc\nf\ngh\n");
   if (string [3] != 0x0A)
       goto Fail;
   if (string [5] != 0x0A)
       goto Fail;
   if (string [8] != 0x0A)
       goto Fail;

   printf ("Passed Conformance Test 2.1.1.2\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 2.1.1.2\n");
 }
