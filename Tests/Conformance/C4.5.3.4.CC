/* Conformance Test 4.5.3.4: Verfication of static array declarations: arrays */
/*                           of pointers                                      */

#include <math.h>

static   int       *i1 [50];                               /* all basic types */
static   long      *L1 [9];
static   comp      *c1 [3];
static   char      *ch1 [10];
static   float     *f1 [3];
static   double    *d1 [8];
static   extended  *e1 [9];

static   unsigned int  ui3 [4] [5] [1], *ui1 [7];
static   unsigned long ul2 [5] [3], *ul1 [1];

                                                       /* conglomerate types */
struct s { int   a;
           float f; };
static struct s *s1 [10], S;

enum colors { red, black, green };
static enum colors *en [6], C;

union longOrShort { int  first;
                    long second; };
static union longOrShort *u1 [12], U;


main ()
  {
   static int TestEm (void);

   if (TestEm())
       printf ("Passed Conformance Test 4.5.3.4\n");
   else
       printf ("Failed Conformance Test 4.5.3.4\n");
  }

/****************************************************************************/

static  int  TestEm (void)
  {

   char     ch;
   comp     cmp;
   int      i, j, k, n;                                    /* loop indices */
   long     L;                                             /* l-values     */
   float    f;
   double   d;
   extended e;
   unsigned int  ui;
   unsigned long ul;


   for (i = 0; i < 10; i++)            /* assign & check singly-dimensioned */
       ch1 [i] = &ch;                  /*   array of pointers to character  */
   ch = 'z';
   for (i = 9; i >= 0; i--)
       if (*(ch1 [i]) != 'z')
           goto Fail;

   for (i = 0; i < 50; i++)            /* assign & check singly-dimensioned */
       i1 [i] = &n;                    /*   array of pointers to int        */
   n = 32767;
   for (i = 49; i >= 0; i--)
       if (*(i1 [i]) != 32767)
           goto Fail;

   for (i = 8; i >= 0; i--)            /* assign & check singly-dimensioned */
       L1 [i] = &L;                    /*   array of pointers to long int   */
   L = 2147483647;
   for (i = 0; i < 9; i++)
       if (*(L1 [i]) != 2147483647)
           goto Fail;

   for (i = 0; i < 7; i++)               /* assign & check singly-dimensioned */
       ui1 [i] = &ui;                    /*   array of ptrs to unsigned int   */
   ui = 65535;
   for (i = 6; i >= 0; i--)
       if (*(ui1 [i]) != 65535)
           goto Fail;

   ul1 [0] = &ul;                      /* assign & check singly-dimensioned   */
   ul = 4294967295ul;                  /*   array of ptrs to long unsigned int*/
   if (*(ul1 [0]) != 0xffffffff)
       goto Fail;

   for (i = 0; i < 3; i++)             /* assign & check singly-dimensioned */
       c1 [i] = &cmp;                  /*   array of pointers to comp       */
   cmp = 4;
   for (j = 2; j >= 0; j--)
       if (*(c1 [j]) != 4)
           goto Fail;

   f1 [0] = f1 [1] = f1 [2] = &f;      /* assign & check singly-dimensioned */
   f = 32.8;                           /*   array of pointers to float      */
   for (k = 0; k < 3; k++)
       if (fabs(*(f1 [k]) - 32.8) > 0.00001)
           goto Fail;

   for (i = 0; i < 8; i++)                         /* assign & check singly- */
       d1 [i] = &d;                                /*  dimensioned array of  */
   d = 123.0e50;                                   /*  pointers to double    */
   for (k = 7; k >= 0; k--)
       if (fabs(*(d1 [k]) - 0.123E53) > 0.00001)
           goto Fail;

   for (k = 8; k >= 0; k--)            /* assign & check singly-dimensioned */
       e1 [k] = &e;                    /*   array of pointers to extended   */
   e = 0.0e-300;
   for (i = 0; i < 9; i++)
       if (*(e1 [i]) != 0)
           goto Fail;

   for (i = 0; i < 10; i++)            /* assign & check singly-dimensioned */
       s1 [i] = &S;                    /*   array of pointers to structures */
   S.a = 7;
   S.f = 6.4;
   for (i = 9; i >= 0; i--)
       if ((s1 [i]->a != 7) || (fabs(s1 [i]->f - 6.4) > 0.00001))
           goto Fail;

   for (n = 5; n >= 0; n--)            /* assign & check singly-dimensioned  */
       en [n] = &C;                    /*   array of pointers to enumerations*/
   C = black;
   for (k = 0; k < 6; k++)
       if (*(en [k]) != 1)
           goto Fail;

   for (i = 0; i < 12; i++)            /* assign & check singly-dimensioned */
       u1 [i] = &U;                    /*   array of pointers to union      */
   U.first = -45;
   for (k = 11; k >= 0; k--)
       if (u1 [k]->first != -45)
           goto Fail;

   U.second = 32770;
   for (n = 11; n >= 0; n--)
       if (u1 [n]->second != 32770)
           goto Fail;

   return 1;

Fail:
   return 0;
  }
