/* Conformance Test 21.1.0.2:  Verification of assert, ndebug macros */

#include <assert.h>
#define NDEBUG 1

main ()
  {
   int i = 7;
   assert (i == 7);
   printf ("Passed Conformance Test 21.1.0.2\n");
  }
