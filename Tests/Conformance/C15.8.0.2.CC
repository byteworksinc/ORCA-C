/* Conformance Test 15.8.0.2:  Verification of strtol, strtoul functions */

#include <stdlib.h>
#include <limits.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>

void main (void)
  {
            long L1;
   unsigned long UL1;

   char  string [] = "  -2147483647  0xfFfFfFfF  1111  077 0xffffffffff zz ";
   char  *strPtr;


   L1 = strtol (string, &strPtr, 0);
   if (L1 != -(0x7fFfFfff))
       goto Fail;
   if (strPtr != &string [13])
       goto Fail;

   UL1 = strtoul (strPtr, &strPtr, 16);      /* bases 10-36 can be letters */
   if (UL1 != 4294967295ul)
       goto Fail;
   if (strPtr != &string [25])
       goto Fail;

   L1 = strtol (strPtr, &strPtr, 2);
   if (L1 != 15)
       goto Fail;
   if (strPtr != &string [31])
       goto Fail;

   UL1 = strtoul (strPtr, &strPtr, 8);
   if (UL1 != 63)
       goto Fail;
   if (strPtr != &string [36])
       goto Fail;

   L1 = strtol (strPtr, &strPtr, 16);
   if (errno != ERANGE)
       goto Fail;

   UL1 = strtoul (strPtr, &strPtr, 16);
   if (errno != ERANGE)
       goto Fail;

   L1 = strtol ("zz", &strPtr, 0);
   if (errno != ERANGE)
       goto Fail;

   UL1 = strtoul ("xx", &strPtr, 0);
   if (errno != ERANGE)
       goto Fail;

   printf ("Passed Conformance Test 15.8.0.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 15.8.0.2\n");
  }
