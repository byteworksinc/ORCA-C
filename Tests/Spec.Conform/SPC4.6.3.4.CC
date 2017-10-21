/* Special Conformance Test 4.6.3.4:  Verification of static & extern pointer */
/*                                    initializers: setting pointer to element*/
/*                                    of a static or extern array.            */
/*                                                                            */
/* Other files needed: spc4634.1.cc - separately compiled file which accesses */
/*                                    external addresses initialized here     */
/*                     spc4634.exec - EXEC file which separately compiles the */
/*                                    two source files and then links and     */
/*                                    executes them to perform the test       */

#include <math.h>

/* static and extern pointer variables can use only constant expressions */

struct S { int   a;
           float b; };
union  U { int  i;
           long L; };

/* Declare and initialize static arrays */

static int     I1  [2] = { 1, 2 };
static char    Ch1 [2] = { 'a', 'b' };
static long    L1  [2] = { 32778, };
static comp    C1  [2] = { 65535, 978 };
static float   F1  [2] = { 1.1, 3.4 };
static double  D1  [2] = { 2.2, 3.7 };
static extended E1  [2] = { 3.0, 4.0 };

static unsigned int  UI1 [2] = { 0xFFFF, 0xabcd };
static unsigned long UL1 [2] = { 0xFFFFFFFF, 0xef010101 };

static struct S S1 [2] = { 4, 8.0, 10, 20.5 };
static union  U U1 [2] = { 3, 32767 };


/* Declare and initialize extern variables */

int     I2  [2] = { 8, 9 };
char    Ch2 [2] = { 'x', 'z' };
long    L2  [2] = { 17, 27 };
comp    C2  [2] = { 45000, 100000 };
float   F2  [2] = { 123.456, 12.3456 };
double  D2  [2] = { 0.5e10, 0.65 };
extended E2  [2] = { 7.4, 4.7 };

unsigned int  UI2 [2] = { 10, 20 };
unsigned long UL2 [2] = { 4, 88 };

struct S S2 [2] = { 888, 8.88, 999, 9.99 };
union  U U2 [2] = { 7777 };


/* Initialize pointer variables to array addresses */

static int      (*i1Ptr)  = &I1 [1];
static char     (*ch1Ptr) = &Ch1 [1];
static long     (*L1Ptr)  = &L1 [1];
static comp     (*c1Ptr)  = &C1 [1];
static float    (*f1Ptr)  = &F1 [1];
static double   (*d1Ptr)  = &D1 [1];
static extended (*e1Ptr)  = &E1 [1];

static unsigned int (*ui1Ptr)  = &UI1 [1];
static unsigned long (*uL1Ptr) = &UL1 [1];

static struct S (*struct1Ptr) = &S1 [1];
static union  U (*union1Ptr ) = &U1 [1];

int      (*i2Ptr)  = &I2 [1];
char     (*ch2Ptr) = &Ch2 [1];
long     (*L2Ptr)  = &L2 [1];
comp     (*c2Ptr)  = &C2 [1];
float    (*f2Ptr)  = &F2 [1];
double   (*d2Ptr)  = &D2 [1];
extended (*e2Ptr)  = &E2 [1];

unsigned int  (*ui2Ptr) = &UI2 [1];
unsigned long (*uL2Ptr) = &UL2 [1];

struct S (*struct2Ptr) = &S2 [1];
union  U (*union2Ptr ) = &U2 [1];


main ()
  {
   int count = 0;
   extern int ExternTest (void);

   count++;
   if (*(i1Ptr) != 2)
       goto Fail;

   count++;
   if (*(ch1Ptr) != 'b')
       goto Fail;

   count++;
   if (*(L1Ptr) != 0)
       goto Fail;

   count++;
   if (*c1Ptr != 978)
       goto Fail;

   count++;
   if (fabs (*(f1Ptr) - 3.4) > 0.0001)
       goto Fail;

   count++;
   if (fabs (*(d1Ptr) - 3.7) > 0.0001)
       goto Fail;

   count++;
   if (fabs (*(e1Ptr) - 4.0) > 0.0001)
       goto Fail;

   count++;
   if (*(ui1Ptr) != 0xABCD)
       goto Fail;

   count++;
   if (*(uL1Ptr) != 0xEF010101)
       goto Fail;

   count++;
   if ((struct1Ptr->a != 10) || (fabs (struct1Ptr->b - 20.5) > 0.0001))
       goto Fail;

   count++;
   if (union1Ptr->i != 32767)
       goto Fail;

   count++;
   if ( ExternTest () )
       goto Fail;

   printf ("Passed Special Conformance Test 4.6.3.4\n");
   return 0;

Fail:
   printf ("count = %d\n", count);
   printf ("Failed Special Conformance Test 4.6.3.4\n");
   return 0;
  }
