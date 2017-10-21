/* Conformance Test 4.5.3.2:  Verfication of static array declarations */

#include <math.h>

static int  i1 [50], i3 [3] [5] [8];             /* all basic types */
static long L1 [9], L2 [2] [6];

static unsigned int  ui3 [4] [5] [1], ui1 [7];
static unsigned long ul2 [5] [3], ul1 [1];

static comp     c1 [3], c2 [2] [3];
static char     ch2 [6] [5], ch1 [10];
static float    f1 [3], f4 [2] [3] [1] [4];
static double   d2 [2] [4], d1 [8];
static extended e1 [9], e2 [7] [3];

                                                       /* conglomerate types */
struct s { int   a;
           float f; };
static struct s s1 [10], s2 [5] [4];

enum colors { red, black, green };
static enum colors C3 [2] [1] [3], C1 [6];

union longOrShort { int  first;
                    long second; };
static union longOrShort u2 [3] [3], u1 [12];

main ()
  {
   static int TestArray (void);

   if ( TestArray() )
       printf ("Passed Conformance Test 4.5.3.2\n");
   else
       printf ("Failed Conformance Test 4.5.3.2\n");
  }

/****************************************************************************/

static int TestArray ( void )
  {
   int      i, j, k, n;                           /* loop indices */
   long     L;                                    /* l-values     */
   char     ch;
   float    f;
   double   d;
   extended e;
   unsigned int  ui;
   unsigned long ul;

   for (i = 0; i < 50; i++)            /* assign & check singly-dimensioned */
       i1 [i] = i;                     /*   integer array                   */
   for (i = 49; i >= 0; i--)
       if (i1 [i] != i)
           goto Fail;

   for (i = 0; i < 3; i++)             /* assign & check multiply-dimensioned */
       for (j = 0; j < 5; j++)         /*   integer array                     */
           for (k = 0; k < 8; k++)
               i3 [i] [j] [k] = k;
   for (i = 2; i >= 0; i--)
       for (j = 4; j >= 0; j--)
           for (k = 7; k >= 0; k--)
               if (i3 [i] [j] [k] != k)
                   goto Fail;

   for (ch = 'a', i = 0; i < 6; i++)   /* assign & check multiply-dimensioned */
       for (j = 0; j < 5; j++)         /*   character arrays                  */
           ch2 [i] [j] = ch++;
   for (ch = '~', n = 5; n >= 0; n--)
       for (k = 4; k >= 0; k--)
           if (ch2 [n] [k] != ch--)
               goto Fail;

   for (i = 0; i < 10; i++)            /* assign & check singly-dimensioned */
       ch1 [i] = (char) (i + 0x41);    /*   character arrays                */
   for (ch = 'J', i = 9; i >= 0; i--)
       if (ch1 [i] != ch--)
           goto Fail;

   for (i = 8; i >= 0; i--)            /* assign & check singly-dimensioned */
       L1 [i] = 2147483647;            /*   long integer array              */
   for (i = 0; i < 9; i++)
       if (L1 [i] != 2147483647)
           goto Fail;

   for (L = 2147483646, i = 0; i < 2; i++)     /* assign & check multiply-  */
       for (j = 0; j < 6; j++)                 /*   dimensioned long integer*/
           L2 [i] [j] = L--;                   /*   array                   */
   for (L = 2147483635, i = 1; i >= 0; i--)
       for (j = 5; j >= 0; j--)
           if (L2 [i] [j] != L++)
               goto Fail;

   for (ui = 65534, i = 0; i < 7; i++)   /* assign & check singly-dimensioned */
       ui1 [i] = ui--;                   /*   unsigned integer array          */
   for (ui = 65528, i = 6; i >= 0; i--)
       if (ui1 [i] != ui++)
           goto Fail;

   for (ui = 65534, i = 0; i < 4; i++) /* assign & check multiply-dimensioned */
       for (j = 0; j < 5; j++)         /*   unsigned integer array            */
           for (k = 0; k < 1; k++)
               ui3 [i] [j] [k] = ui--;
   for (ui = 65515, i = 3, k = 0; i >= 0; i--)
       for (j = 4; j >= 0; j--)
           if (ui3 [i] [j] [k] != ui++)
               goto Fail;

   for (ul = 4294967279ul, i = 0; i < 5; i++)  /* assign & check multiply- */
       for (j = 0; j < 3; j++)                 /*   dimensioned unsigned   */
           ul2 [i] [j] = ul++;                 /*   long integer array     */
   for (ul = 4294967293ul, i = 4; i >= 0; i--)
       for (j = 2; j >= 0; j--)
           if (ul2 [i] [j] != ul--)
               goto Fail;

   ul1 [0] = ul;                       /* assign & check singly-dimensioned */
   if (ul1 [0] != 4294967278ul)        /*   unsigned long integer array     */
       goto Fail;

   for (i = 0; i < 3; i++)             /* assign & check singly-dimensioned */
       c1 [i] = i;                     /*   comp array                      */
   for (j = 2; j >= 0; j--)
       if (c1 [j] != j)
           goto Fail;

   for (i = 0; i < 2; i++)             /* assign & check multiply-dimensioned */
       for (j = 0; j < 3; j++)         /*   comp array                        */
           c2 [i] [j] = 0;
   for (k = 1; k >= 0; k--)
       for (i = 2; i >= 0; i--)
           if (c2 [i] [j] != 0)
               goto Fail;

   f1 [0] = f1 [1] = f1 [2] = 43.8;    /* assign & check singly-dimensioned */
   for (k = 0; k < 3; k++)             /*   float array                     */
       if (fabs(f1 [k] - 43.8) > 0.00001)
           goto Fail;

   for (f = 1.0, i = 0; i < 2; i++)    /* assign & check multiply-dimensioned */
       for (j = 0; j < 3; j++)         /*   float array                       */
           for (k = 0; k < 1; k++)
               for (n = 0; n < 4; n++)
                   f4 [i] [j] [k] [n] = f++;

   for (f = 1.0, i = 0; i < 2; i++)
       for (j = 0; j < 3; j++)
           for (k = 0; k < 1; k++)
               for (n = 0; n < 4; n++)
                  if (fabs(f4 [i] [j] [k] [n] - f++) > 0.00001)
                      goto Fail;

   for (i = 0; i < 2; i++)             /* assign & check multiply-dimensioned */
       for (j = 0; j < 4; j++)         /*   double array                      */
           d2 [i] [j] = 0.00;
   for (d = 0, k = 1; k >= 0; k--)
       for (i = 3; i >= 0; i--)
           if (d2 [k] [i] != d)
               goto Fail;

   for (d1 [0] = 5.6, i = 1; i < 8; i++)       /* assign & check singly-    */
       d1 [i] = d1 [i-1] + 1.0;                /*  dimensioned double array */
   for (d = 12.6, k = 7; k >= 0; k--)
       if (d1 [k] != d--)
           goto Fail;

   for (e = 96e-75, i = 0; i < 7; i++) /* assign & check multiply-dimensioned */
       for (j = 0; j < 3; j++)         /*   extended array                    */
           e2 [i] [j] = e;
   for (i = 0; i < 7; i++)
       for (j = 0; j < 3; j++)
           if (fabs(e2 [i] [j] - 96.0e-75) > 0.00001)
               goto Fail;

   for (k = 8; k >= 0; k--)            /* assign & check singly-dimensioned */
       e1 [k] = 0;                     /*   extended array                  */
   for (e = 0.000, i = 0; i < 9; i++)
       if (e1 [i] != e)
           goto Fail;

   for (i = 0; i < 10; i++)            /* assign & check singly-dimensioned */
     {                                 /*   array of structures             */
       s1 [i].a = i;
       s1 [i].f = (float) i * 2.0;
     }
   for (i = 0; i < 10; i++)
       if ((s1 [i].a != i) || (fabs(s1 [i].f - i * 2.0) > 0.00001))
           goto Fail;

   for (n = 32766, f = 29.8E10, i = 0; i < 5; i++) /* assign & check multipy- */
       for (j = 0; j < 4; j++)                     /*   dimensioned array of  */
         {                                         /*   structures            */
           s2 [i] [j].a = n--;
           s2 [i] [j].f = f;
         }

   for (n = 32766, f = 29.8e10, i = 0; i < 5; i++)
       for (j = 0; j < 4; j++)
           if ((s2 [i] [j].a != n--) || (fabs(s2 [i] [j].f - f) > 0.00001))
               goto Fail;

   for (i = 1, j = 0, k = 0; k < 3; k++)          /* assign & check multiply- */
       C3 [i] [j] [k] = red;                      /*   dimensioned array of   */
   for (i = 0, k = 0; k < 3; k++)                 /*   enumerations           */
       C3 [i] [j] [k] = green;
   for (k = 0; k < 3; k++)
       if (C3 [0] [0] [k] != green)
           goto Fail;
   for (k = 0; k < 3; k++)
       if (C3 [1] [0] [k] != red)
           goto Fail;

   for (n = 5; n >= 0; n--)                        /* assign & check singly- */
       C1 [n] = black;                             /*   dimensioned array of */
   for (k = 0; k < 6; k++)                         /*   enumerations         */
       if (C1 [k] != 1)
           goto Fail;

   for (i = 0; i < 3; i++)                       /* assign & check multiply- */
       for (j = 0; j < 3; j++)                   /*   dimensioned array of   */
           u2 [i] [j].first = j;                 /*   unions                 */
   for (n = 2; n >= 0; n--)
       if (u2 [n] [0].first != 0)
           goto Fail;
   for (n = 2; n >= 0; n--)
       if (u2 [n] [1].first != 1)
           goto Fail;
   for (n = 2; n >= 0; n--)
       if (u2 [n] [2].first != 2)
           goto Fail;

   for (L = 2147483646, i = 0; i < 3; i++)
       for (j = 0; j < 3; j++)
           u2 [i] [j].second = L--;
   for (L = 2147483646, i = 0; i < 3; i++)
       for (j = 0; j < 3; j++)
           if (u2 [i] [j].second != L--)
               goto Fail;

   for (i = 0; i < 12; i++)            /* assign & check singly-dimensioned */
       u1 [i].first = i;               /*   array of unions                 */
   for (k = 11; k >= 0; k--)
       if (u1 [k].first != k)
           goto Fail;

   for (L = 32767, j = 0; j < 12; j++)
       u1 [j].second = L++;
   for (L = 32767, j = 0; j < 12; j++)
       if (u1[j].second != L++)
           goto Fail;

   return (1);

Fail:
   return (0);
  }
