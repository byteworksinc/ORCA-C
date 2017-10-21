/* Conformance Test 4.6.3.2:  Verification of local pointer initializers */

#include <math.h>

struct S { int   a;
           float b; };
union  U { int  i;
           long L; };
enum   E { a, b, c };


/******************************************************************************/

int I1 (void)
  {
   return 32760;
  }

/******************************************************************************/

long Long1 (void)
  {
   return 2147483647;
  }

/******************************************************************************/

char Ch1 (void)
  {
   return 'm';
  }

/******************************************************************************/

extended E1 (void)
  {
   return 189.0E50;
  }


/******************************************************************************/

main ()
  {

   static int IDisp (int (*func) (void));          /* declare dispatcher rtns */
   static char ChDisp (char (*func) (void));
   static long LDisp (long (*func) (void));
   static extended EDisp (extended (*func) (void));

   int      i1  = 8 * 10;                          /* define local variables */
   char     ch1 = 'P';
   long     L1  = { 0x12345678 - 0x78 };
   comp     c1  = { 0x12345678 };
   float    f1  = 98.6e-00;
   double   d1  = 15.7e10;
   extended e1  = 9.8E45;

   unsigned int  ui1 = 65535;
   unsigned long ul1 = { 42959796 };

   struct S struct1 = { 3, 3.3 };
   union  U union1  = 5;
   enum   E enum1   = c;

   int      i2  [2] = { 160, 140 };                /* define local arrays */
   char     ch2 [2] = { 'e', 'O' };
   long     L2  [2] = { 40, 0x12345600 };
   comp     c2  [2] = { 0x12345678, 0x12345678 };
   float    f2  [2] = { 1.0, 1.0 };
   double   d2  [2] = { 15.7e10, 1.0 };
   extended e2  [2] = { 9.8E45, 8.9E-45 };

   unsigned int  ui2 [2] = { 0x3FFF };
   unsigned long ul2 [2] = { 0x51f0768 };


   int      (*i3Ptr)  (void) = I1;                 /* pointers to functions */
   char     (*ch3Ptr) (void) = Ch1;
   long     (*L3Ptr)  (void) = Long1;
   extended (*e3Ptr)  (void) = E1;

   int      *i4Ptr =  i2;                          /* array names */
   char     *ch4Ptr = ch2 + 1;
   long     *L4Ptr =  L2 + 1;
   comp     *c4Ptr =  c2 + 2 - 1;
   float    *f4Ptr =  f2;
   double   *d4Ptr =  d2 - 0;
   extended *e4Ptr =  e2 + 1;

   unsigned int  *ui4Ptr = ui2;
   unsigned long *uL4Ptr = ul2 + 1;

   struct S *struct5Ptr = &struct1;           /* addresses of local variables */
   union  U *union5Ptr  = &union1;
   enum   E *enum5Ptr   = &enum1;

   int      *i5  = &i1;
   char     *ch5 = &ch1;
   long     *L5  = &L1;
   comp     *c5  = &c1;
   float    *f5  = &f1;
   double   *d5  = &d1;
   extended *e5  = &e1;

   unsigned int  *ui5 = &ui1;
   unsigned long *ul5 = &ul1;


   /* First ensure correctness of pointers to scalars */

   if ((*i5 != 80) || (*ch5 != 'P') || (*L5 != 0x12345600) ||
       (*c5 != 0x12345678) || (fabs(*f5 - 98.6) > 0.00001) ||
       (fabs(*d5 - 15.7e10) > 0.00001) ||
       (fabs(*e5 - 9.8e45) > 0.00001) || (*ui5 != 65535) || (*ul5 != 42959796))
       goto Fail;

   /* Verify pointers to local arrays */

   if (*i4Ptr != 160) goto Fail;
   if (*ch4Ptr != 'O') goto Fail;
   if (*L4Ptr != 0x12345600) goto Fail;
   if (*c4Ptr != 0x12345678) goto Fail;
   if (fabs(*f4Ptr - 1.0) > 0.00001) goto Fail;
   if (fabs(*d4Ptr - 15.7E10) > 0.00001) goto Fail;
   if (fabs(*e4Ptr - 8.9E-45) > 1e-50) goto Fail;
   if (*ui4Ptr != 0x3FFF) goto Fail;
   if (*uL4Ptr != 0) goto Fail;
   if (struct5Ptr->a != 3) goto Fail;
   if (fabs(struct5Ptr->b - 3.3) > 0.00001) goto Fail;
   if (union5Ptr->i != 5) goto Fail;
   if (*enum5Ptr != c) goto Fail;

   /* Verify pointers to functions */

   i1 = IDisp (i3Ptr);
   if (i1 != 32760)
       goto Fail;

   ch1 = ChDisp (ch3Ptr);
   if (ch1 != 'm')
       goto Fail;

   L1 = LDisp (L3Ptr);
   if (L1 != 2147483647)
       goto Fail;

   e1 = EDisp (e3Ptr);
   if (fabs(e1 - 189.0E50) > 0.00001)
       goto Fail;


   printf ("Passed Conformance Test 4.6.3.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.6.3.2\n");
  }


/******************************************************************************/

static int IDisp (int (*func) (void))
  {
   return func ();
  }

/******************************************************************************/

static char ChDisp (char (*func) (void))
  {
   return func ();
  }

/******************************************************************************/

static long LDisp (long (*func) (void))
  {
   return func ();
  }

/******************************************************************************/

static extended EDisp (extended (*func) (void))
  {
   return func ();
  }
