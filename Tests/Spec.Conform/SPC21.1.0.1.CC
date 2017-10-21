/* Special Conformance Test 21.1.0.1:  Verification of assert, ndebug macros */
/*                                                                           */
/* The tester should verify that the program halts with the error message:   */
/* "Assertion failed:  file spc21.1.0.1.cc, line 14"                         */

#undef     NDEBUG
#include   <assert.h>

main ()
  {
   assert (0);
   printf ("Failed Special Conformance Test 21.1.0.1\n");
  }
