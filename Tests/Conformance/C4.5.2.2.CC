/* Conformance Test 4.5.2.2:  Verification of pointer declarators for local */
/*                            data using the typedef storage class          */

#include <math.h>

main ()
  {
                                       /* pointers to all the basic types */
   typedef int *intPtr;
   intPtr  iPtr;
   int     i;

   typedef long *longPtr;
   longPtr lPtr;
   long L;

   typedef unsigned int *uintPtr;
   uintPtr uiPtr;
   unsigned int ui;

   typedef unsigned long *ulongPtr;
   ulongPtr ulPtr;
   unsigned long ulong;

   typedef comp *compPtr;
   compPtr cmpPtr;
   comp cmp;

   typedef char *charPtr;
   charPtr chPtr;
   char ch;

   typedef float *floatPtr;
   floatPtr flPtr;
   float fl;

   typedef double *doublePtr;
   doublePtr dblPtr;
   double dbl;

   typedef extended *extPtr;
   extPtr ePtr;
   extended ext;

                                       /* pointers to conglomerate types */

   struct s { int a;
              long L; };
   typedef struct s *structPtr;
   structPtr sPtr;
   struct s s;

   enum colors { red, black, green };
   typedef enum colors *colorPtr;
   colorPtr colPtr;
   enum colors color;

   union longOrShort { int first;
                       long second; };
   typedef union longOrShort *unionPtr;
   unionPtr unPtr;
   union longOrShort un;

   iPtr = &i;
   i    = 3;
   if (*iPtr != 3)
       goto Fail;

   lPtr = &L;
   L    = 32769;
   if (*lPtr != 32769)
       goto Fail;

   uiPtr = &ui;
   ui    = 65535;
   if (*uiPtr != 65535)
       goto Fail;

   ulPtr = &ulong;
   ulong = 4294967295ul;
   if (*ulPtr != 4294967295ul)
       goto Fail;

   cmpPtr = &cmp;
   cmp    = 4294967295ul;
   if (*cmpPtr != 4294967295ul)
       goto Fail;

   chPtr = &ch;
   ch    = 'A';
   if (*chPtr != 'A')
       goto Fail;

   flPtr = &fl;
   fl    = 123.456;
   if (fabs(*flPtr - 123.456) > 0.00001)
       goto Fail;

   dblPtr = &dbl;
   dbl    = 0.0;
   if (*dblPtr != 0.0)
       goto Fail;

   ePtr = &ext;
   ext  = 12.3e20;
   if (fabs(*ePtr - 123.0E19) >0.00001)
       goto Fail;

   sPtr = &s;
   s.a  = 32767;
   s.L  = 2147483647;
   if ((sPtr->L != 2147483647) || (sPtr->a != 32767))
       goto Fail;

   iPtr = &(s.a);
   if (*iPtr != 32767)
       goto Fail;

   lPtr = &(s.L);
   if (*lPtr != 2147483647)
       goto Fail;

   colPtr = &color;
   color  = black;
   if (*colPtr != black)
       goto Fail;

   unPtr    = &un;
   un.first = 12;
   if (unPtr->first != 12)
       goto Fail;
   un.second = 2147483646;
   if (unPtr->second != 2147483646)
       goto Fail;

   printf ("Passed Conformance Test 4.5.2.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.5.2.2\n");
  }
