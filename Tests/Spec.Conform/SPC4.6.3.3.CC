/* Special Conformance Test 4.6.3.3:  Verification of static & extern pointer */
/*                                    initializers:  setting pointer to name  */
/*                                    of a static or extern variable.         */
/*                                                                            */
/* Other files needed: spc4633.1.cc - separately compiled file which accesses */
/*                                    external arrays initialized here        */
/*                     spc4633.exec - EXEC file which separately compiles the */
/*                                    two source files and then links and     */
/*                                    executes them to perform the test       */

#include <math.h>

/* static and extern pointer variables can use only constant expressions */

struct S { int   a;
           float b; };
union  U { int  i;
           long L; };

/* Declare and initialize static variables */

static int     I1   = { 1,  };
static char    Ch1  = { 'a',  };
static long    L1   = { 32778,  };
static comp    C1   = { 65535,  };
static float   F1   = { 1.1, };
static double  D1   = { 2.2, };
static extended E1   = { 3.0, };

static unsigned int  UI1  = { 0xFFFF,  };
static unsigned long UL1  = { 0xFFFFFFFF,  };

static struct S S1  = { 4, 8.0 };
static union  U U1  = { 3 };


/* Declare and initialize extern variables */

int     I2   = { 8, };
char    Ch2  = { 'x', };
long    L2   = { 17, };
comp    C2   = { 45000, };
float   F2   = { 123.456, };
double  D2   = { 0.5e10,  };
extended E2   = { 7.4, };

unsigned int  UI2  = { 10,  };
unsigned long UL2  = { 4,  };

struct S S2  = { 888, 8.88, };
union  U U2  = { 7777 };


/* initialize pointer variables to names of static and extern variables */

static int      (*i1Ptr)  = &I1;
static char     (*ch1Ptr) = &Ch1;
static long     (*L1Ptr)  = &L1;
static comp     (*c1Ptr)  = &C1;
static float    (*f1Ptr)  = &F1;
static double   (*d1Ptr)  = &D1;
static extended (*e1Ptr)  = &E1;

static unsigned int (*ui1Ptr)  = &UI1;
static unsigned long (*uL1Ptr) = &UL1;

static struct S (*struct1Ptr) = &S1;
static union  U (*union1Ptr ) = &U1;

int      (*i2Ptr)  = &I2;
char     (*ch2Ptr) = &Ch2;
long     (*L2Ptr)  = &L2;
comp     (*c2Ptr)  = &C2;
float    (*f2Ptr)  = &F2;
double   (*d2Ptr)  = &D2;
extended (*e2Ptr)  = &E2;

unsigned int  (*ui2Ptr) = &UI2;
unsigned long (*uL2Ptr) = &UL2;

struct S (*struct2Ptr) = &S2;
union  U (*union2Ptr ) = &U2;


main ()
  {
   int count = 0;
   extern int ExternTest (void);

   count++;
   if (*(i1Ptr) != 1)
       goto Fail;

   count++;
   if (*(ch1Ptr) != 'a')
       goto Fail;

   count++;
   if (*(L1Ptr) != 32778)
       goto Fail;

   count++;
   if (*(c1Ptr) != 65535)
       goto Fail;

   count++;
   if (fabs (*(f1Ptr) - 1.1) > 0.0001)
       goto Fail;

   count++;
   if (fabs (*(d1Ptr) - 2.2) > 0.0001)
       goto Fail;

   count++;
   if (fabs (*(e1Ptr) - 3.0) > 0.0001)
       goto Fail;

   count++;
   if (*(ui1Ptr) != 0xFFFF)
       goto Fail;

   count++;
   if (*(uL1Ptr) != 0xffffffff)
       goto Fail;

   count++;
   if ((struct1Ptr->a != 4) || (fabs (struct1Ptr->b - 8.0) > 0.0001))
       goto Fail;

   count++;
   if (union1Ptr->i != 3)
       goto Fail;

   if ( ExternTest () )
       goto Fail;

   printf ("Passed Special Conformance Test 4.6.3.3\n");
   return;

Fail:
   printf ("count = %d\n", count);
   printf ("Failed Special Conformance Test 4.6.3.3\n");
  }
