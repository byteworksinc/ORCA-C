/* Conformance Test 2.1.2.3:  Ensure '\' can be used to continue preprocessor */
/*                            lines                                           */
#include \
<stdio.h>
#define  CONSTANT \
                    5
main ()
  {
   if (CONSTANT != 5)
       printf ("Failed Conformance Test 2.1.2.3\n");
   else
       printf ("Passed Conformance Test 2.1.2.3\n");
 }
