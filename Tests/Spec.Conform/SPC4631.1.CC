/* Second file containing functions and variables accessed by main to run */
/* test Special Conformance 4.6.3.1                                       */

#include <math.h>

struct S { int   a;
           float b; };
union  U { int  i;
           long L; };

extern int      (*i2Ptr)  (void);            /* declare external variables */
extern char     (*ch2Ptr) (void);
extern long     (*L2Ptr)  (void);
extern comp     (*c2Ptr)  (void);
extern float    (*f2Ptr)  (void);
extern double   (*d2Ptr)  (void);
extern extended (*e2Ptr)  (void);

extern unsigned int  (*ui2Ptr) (void);
extern unsigned long (*uL2Ptr) (void);

extern struct S (*struct2Ptr) (void), extStruct1, extStruct2;
extern union  U (*union2Ptr) (void), extUnion1, extUnion2;


extern int      DispI  (int (*func) (void));   /* declare external functions */
extern char     DispCh (char (*func) (void));
extern long     DispL  (long (*func) (void));
extern comp     DispC  (comp (*func) (void));
extern float    DispF  (float (*func) (void));
extern double   DispD  (double (*func) (void));
extern extended DispE  (extended (*func) (void));

extern unsigned int  DispUI (unsigned int (*func) (void));
extern unsigned long DispUL (unsigned long (*func) (void));

extern struct S DispS (struct S (*func) (void));
extern union  U DispU (union U (*func) (void));


/***************************************************************************/

int ExternTest (void)
  {
   int count = 0;

   int      i;
   char     ch;
   long     LL;
   comp     c;
   float    f;
   double   d;
   extended e;
   unsigned int unInt;
   unsigned long unLong;
   struct S svar;
   union  U uvar;

   count++;
   i = DispI (i2Ptr);
   if (i != 2)
       goto Fail;

   count++;
   ch = DispCh (ch2Ptr);
   if (ch != 'b')
       goto Fail;

   count++;
   LL = DispL (L2Ptr);
   if (LL != 9)
       goto Fail;

   count++;
   c = DispC (c2Ptr);
   if (c != 56)
       goto Fail;

   count++;
   f = DispF (f2Ptr);
   if (fabs (f - 97.9) > 0.0001)
       goto Fail;

   count++;
   d = DispD (d2Ptr);
   if (fabs (d - 25.5e-7) > 0.0001)
       goto Fail;

   count++;
   e = DispE (e2Ptr);
   if (fabs (e - 0.4) > 0.0001)
       goto Fail;

   count++;
   unInt = DispUI (ui2Ptr);
   if (unInt != 0x7E)
       goto Fail;

   count++;
   unLong = DispUL (uL2Ptr);
   if (unLong != 0xFEDCBA98)
       goto Fail;

   count++;
   svar = DispS (struct2Ptr);
   if ((svar.a != 18) || (fabs (svar.b - 0.3) > 0.0001))
       goto Fail;

   count++;
   uvar = DispU (union2Ptr);
   if (uvar.i != 29)
       goto Fail;

   return 0;

Fail:
   printf ("Failed ExternTest: count = %d\n", count);
   return 1;
  }

/***************************************************************************/

int     I2 (void)
  {
   return 2;
  }

/***************************************************************************/

char    Ch2 (void)
  {
   return 'b';
  }

/***************************************************************************/

long    L2 (void)
  {
   return 9;
  }

/***************************************************************************/

comp    C2 (void)
  {
   return 8 * 7;
  }

/***************************************************************************/

float   F2 (void)
  {
   return 97.9;
  }

/***************************************************************************/

double  D2 (void)
  {
   return 25.5e-7;
  }

/***************************************************************************/

extended E2 (void)
  {
   return 0.4;
  }

/***************************************************************************/

unsigned int  UI2 (void)
  {
   return 0x7e;
  }

/***************************************************************************/

unsigned long UL2 (void)
  {
   return 0xfedcba98;
  }

/***************************************************************************/

struct S S2 (void)
  {
   return extStruct2;
  }

/***************************************************************************/

union  U U2 (void)
  {
   return extUnion2;
  }
