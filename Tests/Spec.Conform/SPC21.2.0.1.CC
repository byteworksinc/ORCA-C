/*                                                                       */
/* Special Conformance Test 21.2.0.1:  Verification of system function   */
/*                                                                       */
/* The tester should verify that the shell's CATALOG command is executed */
/* and that status is zero if the command worked.                        */
/*                                                                       */

#include <stdlib.h>

main ()
  {
   int i;
   i = system ("catalog\r");
   exit (i);
  }
