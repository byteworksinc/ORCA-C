/* Special Conformance Test 4.5.2.1:  Verification of pointer declarators for */
/*                                    external data                           */
/*                                                                            */
/* Other files needed: spc4521.exec - EXEC file which separately compiles,    */
/*                                    links, and executes test 4.5.2.1        */
/*                     spc4521.h    - header file containing extern references*/
/*                     spc4521.1.cc - other source file comprising the test   */

#include "spc4521.h"

main ()
  {
   extern void F1 (void);
   F1 ();
  }
