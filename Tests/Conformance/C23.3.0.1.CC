/* Conformance Test 23.3.0.1:  Verification of shellid function */

#include <orca.h>
#include <string.h>

int printf(const char *, ...);

int main (void)
  {
   char *id;

   id = shellid ();
   if (strcmp (id, "BYTEWRKS"))
       goto Fail;

   printf ("Passed Conformance Test 23.3.0.1\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 23.3.0.1\n");
  }
