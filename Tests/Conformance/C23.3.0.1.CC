/* Conformance Test 23.3.0.1:  Verification of shellid function */

#include <orca.h>

main ()
  {
   char *id;

   id = shellid ();
   if (strcmp (id, "BYTEWRKS"))
       goto Fail;

   printf ("Passed Conformance Test 23.3.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 23.3.0.1\n");
  }
