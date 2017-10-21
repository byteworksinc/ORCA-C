/* Conformance Test 4.6.3.1:  Verification of pointer initializers */

/* static and extern pointer variables can use only constant expressions */

#include <stddef.h>

struct S { int   a;
           float b; };
union  U { int  i;
           long L; };
enum   E { a, b, c };

static int      *i1Ptr =  NULL;       /* constant expression can contain NULL */
static char     *ch1Ptr = NULL;
static long     *L1Ptr =  NULL;
static comp     *c1Ptr =  NULL;
static float    *f1Ptr =  NULL;
static double   *d1Ptr =  NULL;
static extended *e1Ptr =  NULL;

static unsigned int *ui1Ptr = NULL;
static unsigned long *uL1Ptr = NULL;

static struct S *struct1Ptr = NULL;
static union  U *union1Ptr  = NULL;
static enum   E *enum1Ptr   = NULL;

int      *i2Ptr =  NULL;
char     *ch2Ptr = NULL;
long     *L2Ptr =  NULL;
comp     *c2Ptr =  NULL;
float    *f2Ptr =  NULL;
double   *d2Ptr =  NULL;
extended *e2Ptr =  NULL;

unsigned int *ui2Ptr = NULL;
unsigned long *uL2Ptr = NULL;

struct S *struct2Ptr = NULL;
union  U *union2Ptr  = NULL;
enum   E *enum2Ptr   = NULL;

main ()
  {
   /* local pointer variables can also be set to NULL */

   int      *i3Ptr =  NULL;
   char     *ch3Ptr = NULL;
   long     *L3Ptr =  NULL;
   comp     *c3Ptr =  NULL;
   float    *f3Ptr =  NULL;
   double   *d3Ptr =  NULL;
   extended *e3Ptr =  NULL;

   unsigned int *ui3Ptr = NULL;
   unsigned long *uL3Ptr = NULL;

   struct S *struct3Ptr = NULL;
   union  U *union3Ptr  = NULL;
   enum   E *enum3Ptr   = NULL;

   if ((i1Ptr != 0) || (i2Ptr != 0) || (i3Ptr != 0))
       goto Fail;

   if ((ch1Ptr != 0) || (ch2Ptr != 0) || (ch3Ptr != 0))
       goto Fail;

   if ((L1Ptr != 0) || (L2Ptr != 0) || (L3Ptr != 0))
       goto Fail;

   if ((c1Ptr != 0) || (c2Ptr != 0) || (c3Ptr != 0))
       goto Fail;

   if ((f1Ptr != 0) || (f2Ptr != 0) || (f3Ptr != 0))
       goto Fail;

   if ((d1Ptr != 0) || (d2Ptr != 0) || (d3Ptr != 0))
       goto Fail;

   if ((e1Ptr != 0) || (e2Ptr != 0) || (e3Ptr != 0))
       goto Fail;

   if ((ui1Ptr != 0) || (ui2Ptr != 0) || (ui3Ptr != 0))
       goto Fail;

   if ((uL1Ptr != 0) || (uL2Ptr != 0) || (uL3Ptr != 0))
       goto Fail;

   if ((struct1Ptr != 0) || (struct2Ptr != 0) || (struct3Ptr != 0))
       goto Fail;

   if ((union1Ptr != 0) || (union2Ptr != 0) || (union3Ptr != 0))
       goto Fail;

   printf ("Passed Conformance Test 4.6.3.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.6.3.1\n");
  }
