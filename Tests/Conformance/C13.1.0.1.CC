/* Conformance Test 13.1.0.1:  Verification of standard library types and */
/*                             NULL                                       */

#include <stddef.h>

extended e1 [800];

main ()
  {
   int i [10] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
   int *i1 = i;
   int *i2 = &i [2];
   long diff;
   unsigned long size;

   static ptrdiff_t TestPtrdiff_t (int *int1Ptr, int *int2Ptr);


   diff = TestPtrdiff_t (i2, i1);
   if (diff != 2)
       goto Fail;

   size = sizeof(e1);
   if (size != 8000)
       goto Fail;

   if (NULL != 0)
       goto Fail;

   printf ("Passed Conformance Test 13.1.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 13.1.0.1\n");
  }


/*****************************************************************************/

static ptrdiff_t TestPtrdiff_t (int *int1Ptr, int *int2Ptr)
  {
   return int1Ptr - int2Ptr;
  }
