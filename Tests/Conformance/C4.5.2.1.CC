/* Conformance Test 4.5.2.1:  Verification of pointer declarators for local */
/*                            data                                          */

#include <math.h>

main ()
  {
   int            *intPtr, i;          /* pointers to all the basic types */
   long           *longPtr, L;
   unsigned  int  *uintPtr, ui;
   unsigned  long *ulongPtr, ulong;
   comp           *compPtr, cmp;
   char           *charPtr, ch;
   float          *floatPtr, fl;
   double         *doublePtr, dbl;
   extended       *extPtr, ext;

                                       /* pointers to conglomerate types */

   struct s           { int a;
                        long L; } *structPtr, s;
   enum   colors      { red, black, green } *colorPtr, color;
   union  longOrShort { int first;
                        long second; } *unionPtr, un;

   intPtr = &i;
   i      = 3;
   if (*intPtr != 3)
       goto Fail;

   longPtr = &L;
   L       = 32769;
   if (*longPtr != 32769)
       goto Fail;

   uintPtr = &ui;
   ui      = 65535;
   if (*uintPtr != 65535)
       goto Fail;

   ulongPtr = &ulong;
   ulong    = 4294967295ul;
   if (*ulongPtr != 4294967295ul)
       goto Fail;

   compPtr = &cmp;
   cmp     = 4294967295ul;
   if (*compPtr != 4294967295ul)
       goto Fail;

   charPtr = &ch;
   ch      = 'A';
   if (*charPtr != 'A')
       goto Fail;

   floatPtr = &fl;
   fl       = 123.456;
   if (fabs(*floatPtr - 123.456) > 0.00001)
       goto Fail;

   doublePtr = &dbl;
   dbl       = 0.0;
   if (*doublePtr != 0.0)
       goto Fail;

   extPtr = &ext;
   ext    = 12.3e20;
   if (*extPtr != 123.0E19)
       goto Fail;

   structPtr = &s;
   s.a       = 32767;
   s.L       = 2147483647;
   if ((structPtr->L != 2147483647) || (structPtr->a != 32767))
       goto Fail;

   intPtr = &(s.a);
   if (*intPtr != 32767)
       goto Fail;

   longPtr = &(s.L);
   if (*longPtr != 2147483647)
       goto Fail;

   colorPtr = &color;
   color    = black;
   if (*colorPtr != black)
       goto Fail;

   unionPtr = &un;
   un.first = 12;
   if (unionPtr->first != 12)
       goto Fail;
   un.second = 2147483646;
   if (unionPtr->second != 2147483646)
       goto Fail;

   printf ("Passed Conformance Test 4.5.2.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.5.2.1\n");
  }
