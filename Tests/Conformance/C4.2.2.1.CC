/* Conformance Test 4.2.2.1:  Verify correct identifier "hiding" */

/* Global declarations of all different identifier types in C.   */

#include <math.h>

typedef  int  *numPtr;                 /* user-defined type    */

float  f;                              /* variables            */
double ch;

struct aRecord { int value1;           /* type tag name        */
                 int value2; };        /*   and struct fields  */

union  variantRec { long longNum;      /* type tag name        */
                    int  shortNum; };  /*   and union fields   */

enum flowers { rose, iris, carnation };    /* type tag name    */
                                           /*   and enum const */

int  DoubleCheck (void);                   /* function names   */

/******************************************************************************/

int i (char ch)
  {
   return ch;
  }

/******************************************************************************/

main ()
  {
   int   i;
   typedef float *numPtr;              /* redefine the global types */
   numPtr  f;
   struct variantRec { long longNum;
                       int  shortNum; };
   enum aRecord { rec1, rec2, rec3 };
   union flowers { int  x;
                   long y; };
   struct variantRec r1, *r2;
   enum   aRecord    x, y;
   union  flowers    longNum, Rose;
   float  fp;

   ch = 6.0;
   if (fabs(ch - 6.0) > 0.00001)
       goto Fail;

   fp = 3.1;
   f  = &fp;
   if (fabs(*f - 3.1) > 0.00001)
       goto Fail;

   r1.longNum  = 10;
   r1.shortNum = 12;
   r2          = &r1;
   if ((r2->longNum != 10) || (r2->shortNum != 12))
       goto Fail;

   x = rec1;
   y = rec3;
   if ((x != 0) || (y != 2))
       goto Fail;

   longNum.x = 89;
   longNum.y = 101;
   Rose      = longNum;
   if (Rose.y != 101)
       goto Fail;

   i = DoubleCheck();
   if (i != 0)
       goto Fail;

   printf ("Passed Conformance Test 4.2.2.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.2.2.1\n");
  }

/******************************************************************************/

int DoubleCheck (void)
  {
   numPtr k;
   int    f;

   struct aRecord    R1, *R2;
   union  variantRec value1, value2;
   enum   flowers    dahlia;

   f = i ('a');
   if (f != 0x61)
       goto Fail;

   f = 45;
   k = &f;
   if (*k != 45)
       goto Fail;

   R2 = &R1;
   R2->value1 = 18;
   (*R2).value2 = 27;
   if ((R1.value1 != 18) || (R1.value2 != 27))
       goto Fail;

   value1.shortNum = 111;
   value2          = value1;
   if (value2.shortNum != 111)
       goto Fail;

   dahlia = carnation;
   if (dahlia != 2)
       goto Fail;

   return 0;

Fail:
   return 211;
  }
