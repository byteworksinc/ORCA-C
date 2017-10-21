/* Special Conformance Test 4.6.3.2:  Verification of static & extern pointer */
/*                                    initializers:  setting pointer to name  */
/*                                    of a static or extern array.            */
/*                                                                            */
/* Other files needed: spc4632.1.cc - separately compiled file which accesses */
/*                                    external arrays initialized here        */
/*                     spc4632.exec - EXEC file which separately compiles the */
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
static long    L1  [2] = { 32778, 32889 };
static comp    C1  [2] = { 65535, 65530 };
static float   F1  [2] = { 1.1, 1.2, };
static double  D1  [2] = { 2.2, 2.3, };
static extended E1  [2] = { 3.0, 3.3, };

static unsigned int  UI1 [2] = { 0xFFFF, 0x0011 };
static unsigned long UL1 [2] = { 0xFFFFFFFF, 0x7FFFFFFF };

static struct S S1 [2] = { { 4, 8.0 }, { 10, 15.0 } };
static union  U U1 [2] = { 3 };


/* Declare and initialize extern arrays */

int     I2  [2] = { 8, 9 };
char    Ch2 [2] = { 'x', 'y' };
long    L2  [2] = { 17, 23 };
comp    C2  [2] = { 45000, 500000 };
float   F2  [2] = { 123.456, 6.0e7 };
double  D2  [2] = { 0.5e10, 3.27 };
extended E2  [2] = { 7.4, 9.9 };

unsigned int  UI2 [2] = { 10, 11 };
unsigned long UL2 [2] = { 4, 4 };

struct S S2 [2] = { 888, 8.88, 999, 9.99 };
union  U U2 [2] = { 7777 };


/* initialize pointer variables to names of static and extern arrays */

static int      (*i1Ptr)  = I1;
static char     (*ch1Ptr) = Ch1;
static long     (*L1Ptr)  = L1;
static comp     (*c1Ptr)  = C1;
static float    (*f1Ptr)  = F1;
static double   (*d1Ptr)  = D1;
static extended (*e1Ptr)  = E1;

static unsigned int (*ui1Ptr)  = UI1;
static unsigned long (*uL1Ptr) = UL1;

static struct S (*struct1Ptr) = S1;
static union  U (*union1Ptr ) = U1;

int      (*i2Ptr)  = I2;
char     (*ch2Ptr) = Ch2;
long     (*L2Ptr)  = L2;
comp     (*c2Ptr)  = C2;
float    (*f2Ptr)  = F2;
double   (*d2Ptr)  = D2;
extended (*e2Ptr)  = E2;

unsigned int  (*ui2Ptr) = UI2;
unsigned long (*uL2Ptr) = UL2;

struct S (*struct2Ptr) = S2;
union  U (*union2Ptr ) = U2;


main ()
  {
   int count = 0;
   extern int ExternTest (void);

   count++;
   if ((*(i1Ptr) != 1) || (*(i1Ptr + 1) != 2))
       goto Fail;

   count++;
   if ((*(ch1Ptr) != 'a') || (*(ch1Ptr + 1) != 'b'))
       goto Fail;

   count++;
   if ((*(L1Ptr) != 32778) || (*(L1Ptr + 1) != 32889))
       goto Fail;

   count++;
   if ((*(c1Ptr) != 65535) || (*(c1Ptr + 1) != 65530))
       goto Fail;

   count++;
   if ((fabs (*(f1Ptr) - 1.1) > 0.0001) || (fabs (*(f1Ptr + 1) - 1.2) > 0.0001))
       goto Fail;

   count++;
   if ((fabs (*(d1Ptr) - 2.2) > 0.0001) || (fabs (*(d1Ptr + 1) - 2.3) > 0.0001))
       goto Fail;

   count++;
   if ((fabs (*(e1Ptr) - 3.0) > 0.0001) || (fabs (*(e1Ptr + 1) - 3.3) > 0.0001))
       goto Fail;

   count++;
   if ((*(ui1Ptr) != 0xFFFF) || (*(ui1Ptr + 1) != 0x0011))
       goto Fail;

   count++;
   if ((*(uL1Ptr) != 0xffffffff) || (*(uL1Ptr + 1) != 0x7fffffff))
       goto Fail;

   count++;
   if ((struct1Ptr->a != 4) || ((struct1Ptr + 1)->a != 10))
       goto Fail;

   count++;
   if ((fabs (struct1Ptr->b - 8.0) > 0.0001) ||
       (fabs ((struct1Ptr + 1)->b - 15.0) > 0.0001))
       goto Fail;

   count++;
   if ((union1Ptr->i != 3) || ((union1Ptr + 1)->i != 0))
       goto Fail;

   if ( ExternTest () )
       goto Fail2;

   printf ("Passed Special Conformance Test 4.6.3.2\n");
   return;

Fail:
   printf ("count = %d\n", count);
Fail2:
   printf ("Failed Special Conformance Test 4.6.3.2\n");
  }
