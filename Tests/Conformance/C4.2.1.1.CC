/* Conformance Test 4.2.1.1:  Test scoping of identifiers */

/* Global declarations of all different identifier types in C.             */
/* Each identifier should be available through the end of the source file. */

#include <math.h>

#define MAC_NAME1  10                  /* macro name           */

typedef  int  *intPtr;                 /* user-defined type    */
char     F1 (int x, int y);            /* function name        */

         int i;                        /* variable             */

struct ComplexNum { float real;        /* type tag name        */
                    float imag; };     /*   and struct fields  */

union  LongOrShort { long longNum;     /* type tag name        */
                     int  shortNum; }; /*   and union fields   */

enum flowers { rose, iris, carnation };    /* type tag name    */
                                           /*   and enum const */

main ()
  {
   char   ch;
   int    m;
   intPtr k;
   struct ComplexNum  c, d;
   union  LongOrShort z;
   enum   flowers     f;

   m = 3;
   k = &m;
   if (*k != 3)
       goto Fail;

   c.real = 5.1;
   c.imag = 2.0;
   d      = c;
   if ((fabs(d.real - 5.1) > 0.00001) || (fabs(d.imag - 2.0) > 0.00001))
       goto Fail;

   z.longNum = 5;
   if (z.shortNum != 5)            /* don't ever do this in real life! */
       goto Fail;

   f = carnation;
   if (f != 2)
       goto Fail;

   i = MAC_NAME1;
   if (i != 10)
       goto Fail;

   ch = F1 (3, i);
   if (ch != '\r')
       goto Fail;

   printf ("Passed Conformance Test 4.2.1.1\n");
   return;

   printf ("This code can never be reached !!!\n");

Fail:
   printf ("Failed Conformance Test 4.2.1.1\n");
   return;

   printf ("Nor can this code ever be reached !!!\n");
  }

/****************************************************************************/

char     F1 (int x, int y)
  {
   int    m;
   intPtr k;
   struct ComplexNum  c, *d;
   union  LongOrShort z;
   enum   flowers     f;

   m = 5;
   k = &m;
   if (*k != 5)
       goto Err1;

   c.real = 18.7;
   c.imag = 23.5;
   d      = &c;
   if ((fabs(d->real - 18.7) > 0.00001) || (fabs(d->imag - 23.5) > 0.00001))
       goto Err2;

   z.longNum = 0x7FE5;
   if (z.shortNum != 0x7fe5)       /* don't ever do this in real life! */
       goto Err3;

   #define MAC_NAME2  11

   f = iris;
   if (f != 1)
       goto Fail;

   i = MAC_NAME2;
   if (i != 11)
       goto Fail;

   return (x + y);

Err1:
   return (1);

Err2:
   return (2);

Err3:
   return (3);

Fail:
   return (4);
  }
