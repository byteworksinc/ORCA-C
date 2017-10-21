/* Separately compiled file needed to run Special Conformance Test 4.5.2.1 */

#include <math.h>
#include <limits.h>

/* Global data */

int            *intPtr, i;             /* pointers to all the basic types */
long           *longPtr, L;
unsigned  int  *uintPtr, ui;
unsigned  long *ulongPtr, ulong;
comp           *compPtr, cmp;
char           *charPtr, ch;
float          *floatPtr, fl;
double         *doublePtr, dbl;
extended       *extPtr, ext;

                                       /* pointers to conglomerate types */
struct s  { int a;
            long L; } *structPtr, s;
enum   colors  { red, black, green } *colorPtr, color;
union  longOrShort { int first;
                     long second; } *unionPtr, un;

void F1 (void)
  {
   int count = 0;

   count += 1;
   intPtr = &i;
   i      = 3;
   if (*intPtr != 3)
       goto Fail;

   count += 1;
   longPtr = &L;
   L       = INT_MAX + 2L;
   if (*longPtr != 32769)
       goto Fail;

   count += 1;
   uintPtr = &ui;
   ui      = UINT_MAX;
   if (*uintPtr != 65535u)
       goto Fail;

   count += 1;
   ulongPtr = &ulong;
   ulong    = ULONG_MAX;
   if (*ulongPtr != 4294967295ul)
       goto Fail;

   count += 1;
   compPtr = &cmp;
   cmp     = ulong + 4;
   if (*compPtr != ULONG_MAX + 4)
       goto Fail;

   count += 1;
   charPtr = &ch;
   ch      = 'A';
   if (*charPtr != 'A')
       goto Fail;

   count += 1;
   floatPtr = &fl;
   fl       = 123.456;
   if ( (fabs (*floatPtr - 123.456)) > 0.0001 )
       goto Fail;

   count += 1;
   doublePtr = &dbl;
   dbl       = 0.0;
   if (fabs (*doublePtr - 0.0) > 0.00001)
       goto Fail;

   count += 1;
   extPtr = &ext;
   ext    = 12.3e20;
   if ( (fabs (*extPtr - 123.0E19)) > 0.0001 )
       goto Fail;

   count += 1;
   structPtr = &s;
   s.a       = INT_MAX;
   s.L       = LONG_MAX;
   if ((structPtr->L != 2147483647l) || (structPtr->a != 32767))
       goto Fail;

   count += 1;
   intPtr = &(s.a);
   if (*intPtr != 32767)
       goto Fail;

   count += 1;
   longPtr = &(s.L);
   if (*longPtr != LONG_MAX)
       goto Fail;

   count += 1;
   colorPtr = &color;
   color    = black;
   if (*colorPtr != black)
       goto Fail;

   count += 1;
   unionPtr = &un;
   un.first = 12;
   if (unionPtr->first != 12)
       goto Fail;

   count += 1;
   un.second = 2147483646;
   if (unionPtr->second != 2147483646)
       goto Fail;

   printf ("Passed Special Conformance Test 4.5.2.1\n");
   return;

Fail:
   printf ("Failed Special Conformance Test 4.5.2.1\n");
   printf ("count = %d\n", count);
  }
