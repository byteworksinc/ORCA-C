/* Special Conformance Test 4.6.3.1:  Verification of pointer initializers;  */
/*                                    setting to name of a function.         */
/*                                                                           */
/* Other files needed: spc4631.1.cc - File containing the external functions */
/*                                    called by main                         */
/*                     spc4631.exec - EXEC file which separately compiles,   */
/*                                    links, and executes files to run test  */

#include <math.h>

/* static and extern pointer variables can use only constant expressions */

struct S { int   a;
           float b; };
union  U { int  i;
           long L; };

static int     I1 (void);               /* declare static functions */
static char    Ch1 (void);
static long    L1 (void);
static comp    C1 (void);
static float   F1 (void);
static double  D1 (void);
static extended E1 (void);

static unsigned int  UI1 (void);
static unsigned long UL1 (void);

static struct S S1 (void);
static union  U U1 (void);

extern int     I2 (void);               /* declare extern functions */
extern char    Ch2 (void);
extern long    L2 (void);
extern comp    C2 (void);
extern float   F2 (void);
extern double  D2 (void);
extern extended E2 (void);

extern unsigned int  UI2 (void);
extern unsigned long UL2 (void);

extern struct S S2 (void);
extern union  U U2 (void);

/* initialize variables to name of function */

static int      (*i1Ptr) (void)  = I1;
static char     (*ch1Ptr) (void) = Ch1;
static long     (*L1Ptr) (void)  = L1;
static comp     (*c1Ptr) (void)  = C1;
static float    (*f1Ptr) (void)  = F1;
static double   (*d1Ptr) (void)  = D1;
static extended (*e1Ptr) (void)  = E1;

static unsigned int (*ui1Ptr) (void)  = UI1;
static unsigned long (*uL1Ptr) (void) = UL1;

static struct S (*struct1Ptr) (void) = S1;
static union  U (*union1Ptr ) (void) = U1;

int      (*i2Ptr) (void)  = I2;
char     (*ch2Ptr) (void) = Ch2;
long     (*L2Ptr) (void)  = L2;
comp     (*c2Ptr) (void)  = C2;
float    (*f2Ptr) (void)  = F2;
double   (*d2Ptr) (void)  = D2;
extended (*e2Ptr) (void)  = E2;

unsigned int  (*ui2Ptr) (void) = UI2;
unsigned long (*uL2Ptr) (void) = UL2;

struct S (*struct2Ptr) (void) = S2;
union  U (*union2Ptr ) (void) = U2;


/* Other external variables */

struct S extStruct1 = { 2, 5.7 };
struct S extStruct2 = { 18, 0.3 };
union  U extUnion1  = { 32767 };
union  U extUnion2  = { 29 };


/* Function dispatchers */

/*****************************************************************************/

int DispI (int (*func) (void))
  {
   return (*func) ();
  }

/*****************************************************************************/

char DispCh (char (*func) (void))
  {
   return (*func) ();
  }

/*****************************************************************************/

long DispL (long (*func) (void))
  {
   return (*func) ();
  }

/*****************************************************************************/

comp DispC (comp (*func) (void))
  {
   return (*func) ();
  }

/*****************************************************************************/

float DispF (float (*func) (void))
  {
   return (*func) ();
  }

/*****************************************************************************/

double DispD (double (*func) (void))
  {
   return (*func) ();
  }

/*****************************************************************************/

extended DispE (extended (*func) (void))
  {
   return (*func) ();
  }

/*****************************************************************************/

unsigned int DispUI (unsigned int (*func) (void))
  {
   return (*func) ();
  }

/*****************************************************************************/

unsigned long DispUL (unsigned long (*func) (void))
  {
   return (*func) ();
  }

/*****************************************************************************/

struct S DispS (struct S (*func) (void))
  {
   return (*func) ();
  }

/*****************************************************************************/

union U DispU (union U (*func) (void))
  {
   return (*func) ();
  }

/*****************************************************************************/

main ()
  {
   extern int ExternTest (void);

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
   i = DispI (i1Ptr);
   if (i != 1)
       goto Fail;

   count++;
   ch = DispCh (ch1Ptr);
   if (ch != 'a')
       goto Fail;

   count++;
   LL = DispL (L1Ptr);
   if (LL != 0x65535)
       goto Fail;

   count++;
   c = DispC (c1Ptr);
   if (c != 4294967295ul)
       goto Fail;

   count++;
   f = DispF (f1Ptr);
   if (f != 3.5)
       goto Fail;

   count++;
   d = DispD (d1Ptr);
   if (d != 108.0e20)
       goto Fail;

   count++;
   e = DispE (e1Ptr);
   if (e != 0.123E-300)
       goto Fail;

   count++;
   unInt = DispUI (ui1Ptr);
   if (unInt != 65534)
       goto Fail;

   count++;
   unLong = DispUL (uL1Ptr);
   if (unLong != 0x7F)
       goto Fail;

   count++;
   svar = DispS (struct1Ptr);
   if ((svar.a != 2) || (fabs (svar.b - 5.7) > 0.0001))
       goto Fail;

   count++;
   uvar = DispU (union1Ptr);
   if (uvar.i != 32767)
       goto Fail;

   count++;
   if ( ExternTest () )
       goto Fail;

   printf ("Passed Special Conformance Test 4.6.3.1\n");
   return 0;

Fail:
   printf ("Failed Special Conformance Test 4.6.3.1: count = %d\n", count);
   return 0;
  }

/****************************************************************************/

static int     I1 (void)
  {
   return 1;
  }

/****************************************************************************/

static char    Ch1 (void)
  {
   return 'a';
  }

/****************************************************************************/

static long    L1 (void)
  {
   return  0x65535;
  }

/****************************************************************************/

static comp    C1 (void)
  {
   return 4294967295ul;
  }

/****************************************************************************/

static float   F1 (void)
  {
   return 3.5;
  }

/****************************************************************************/

static double  D1 (void)
  {
   return 108.0E20;
  }

/****************************************************************************/

static extended E1 (void)
  {
   return .123e-300;
  }

/****************************************************************************/

static unsigned int  UI1 (void)
  {
   return 65534;
  }

/****************************************************************************/

static unsigned long UL1 (void)
  {
   return 0x7f;
  }

/****************************************************************************/

static struct S S1 (void)
  {
   return extStruct1;
  }

/****************************************************************************/

static union  U U1 (void)
  {
   return extUnion1;
  }
