/* Conformance Test 15.8.0.1:  Verification of strtod library function */

#include <stdlib.h>
#include <math.h>
#include <errno.h>

main ()
  {
   double d1;
   char   string [] = "  -32767  0567  -3.4e+2  ";
   char   *strPtr;


   d1 = strtod (string, &strPtr);
   if (fabs(d1 - -32767.0) > 0.00001)
       goto Fail;
   if (strPtr != &string [8])
       goto Fail;

   d1 = strtod (strPtr, &strPtr);
   if (fabs(d1 - 567.00) > 0.00001)
       goto Fail;
   if (strPtr != &string [14])
       goto Fail;

   d1 = strtod (strPtr, &strPtr);
   if (fabs(d1 - (-340.00)) > 0.00001)
       goto Fail;
   if (strPtr != &string [23])
       goto Fail;

   printf ("Passed Conformance Test 15.8.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 15.8.0.1\n");
  }
