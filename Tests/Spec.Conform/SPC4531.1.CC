#include <math.h>
#include "spc4531.h"

/****************************************************************************/

int TestArray ( void )
  {
   int count = 0;

   int      i, j, k, n;                           /* loop indices */
   long     L;                                    /* l-values     */
   char     ch;
   float    f;
   double   d;
   extended e;
   unsigned int  ui;
   unsigned long ul;

   count += 1;
   for (i = 0; i < 50; i++)            /* assign & check singly-dimensioned */
       i1 [i] = i;                     /*   integer array                   */
   for (i = 49; i >= 0; i--)
       if (i1 [i] != i)
           goto Fail;

   count += 1;
   for (i = 0; i < 3; i++)             /* assign & check multiply-dimensioned */
       for (j = 0; j < 5; j++)         /*   integer array                     */
           for (k = 0; k < 8; k++)
               i3 [i] [j] [k] = k;
   for (i = 2; i >= 0; i--)
       for (j = 4; j >= 0; j--)
           for (k = 7; k >= 0; k--)
               if (i3 [i] [j] [k] != k)
                   goto Fail;

   count += 1;
   for (ch = 'a', i = 0; i < 6; i++)   /* assign & check multiply-dimensioned */
       for (j = 0; j < 5; j++)         /*   character arrays                  */
           ch2 [i] [j] = ch++;
   for (ch = '~', n = 5; n >= 0; n--)
       for (k = 4; k >= 0; k--)
           if (ch2 [n] [k] != ch--)
               goto Fail;

   count += 1;
   for (i = 0; i < 10; i++)            /* assign & check singly-dimensioned */
       ch1 [i] = (char) (i + 0x41);    /*   character arrays                */
   for (ch = 'J', i = 9; i >= 0; i--)
       if (ch1 [i] != ch--)
           goto Fail;

   count += 1;
   for (i = 8; i >= 0; i--)            /* assign & check singly-dimensioned */
       L1 [i] = 2147483647;            /*   long integer array              */
   for (i = 0; i < 9; i++)
       if (L1 [i] != 2147483647)
           goto Fail;

   count += 1;
   for (L = 2147483646, i = 0; i < 2; i++)     /* assign & check multiply-  */
       for (j = 0; j < 6; j++)                 /*   dimensioned long integer*/
           L2 [i] [j] = L--;                   /*   array                   */
   for (L = 2147483634, i = 1; i >= 0; i--)
       for (j = 5; j >= 0; j--)
           if (L2 [i] [j] != ++L)
               goto Fail;

   count += 1;
   for (ui = 65534, i = 0; i < 7; i++)   /* assign & check singly-dimensioned */
       ui1 [i] = ui--;                   /*   unsigned integer array          */
   for (ui = 65527, i = 6; i >= 0; i--)
       if (ui1 [i] != ++ui)
           goto Fail;

   count += 1;
   for (ui = 65534, i = 0; i < 4; i++) /* assign & check multiply-dimensioned */
       for (j = 0; j < 5; j++)         /*   unsigned integer array            */
           for (k = 0; k < 1; k++)
               ui3 [i] [j] [k] = ui--;
   for (ui = 65514, i = 3, k = 0; i >= 0; i--)
       for (j = 4; j >= 0; j--)
           if (ui3 [i] [j] [k] != ++ui)
               goto Fail;

   count += 1;
   for (ul = 4294967279ul, i = 0; i < 5; i++)  /* assign & check multiply- */
       for (j = 0; j < 3; j++)                 /*   dimensioned unsigned   */
           ul2 [i] [j] = ul++;                 /*   long integer array     */
   for (ul = 4294967294ul, i = 4; i >= 0; i--)
       for (j = 2; j >= 0; j--)
           if (ul2 [i] [j] != --ul)
               goto Fail;

   count += 1;
   ul1 [0] = ul;                       /* assign & check singly-dimensioned */
   if (ul1 [0] != 4294967279ul)        /*   unsigned long integer array     */
       goto Fail;

   count += 1;
   for (i = 0; i < 3; i++)             /* assign & check singly-dimensioned */
       c1 [i] = i;                     /*   comp array                      */
   for (j = 2; j >= 0; j--)
       if (c1 [j] != j)
           goto Fail;

   count += 1;
   for (i = 0; i < 2; i++)             /* assign & check multiply-dimensioned */
       for (j = 0; j < 3; j++)         /*   comp array                        */
           c2 [i] [j] = 0;
   for (k = 1; k >= 0; k--)
       for (i = 2; i >= 0; i--)
           if (c2 [i] [j] != 0)
               goto Fail;

   count += 1;
   f1 [0] = f1 [1] = f1 [2] = 43.8;    /* assign & check singly-dimensioned */
   for (k = 0; k < 3; k++)             /*   float array                     */
       if ( (fabs (f1 [k] - 43.8)) > 0.0001 )
           goto Fail;

   for (f = 1.0, i = 0; i < 2; i++)    /* assign & check multiply-dimensioned */
       for (j = 0; j < 3; j++)         /*   float array                       */
           for (k = 0; k < 1; k++)
               for (n = 0; n < 4; n++)
                   f4 [i] [j] [k] [n] = f++;

   count += 1;
   for (f = 24.0, k = 0, i = 1; i >= 0; i--)
       for (j = 2; j >= 0; j--)
           for (n = 3; n >= 0; n--)
               if (f4 [i] [j] [k] [n] != f--)
                   goto Fail;

   count += 1;
   for (i = 0; i < 2; i++)             /* assign & check multiply-dimensioned */
       for (j = 0; j < 4; j++)         /*   double array                      */
           d2 [i] [j] = 0.00;
   for (d = 0, k = 1; k >= 0; k--)
       for (i = 3; i >= 0; i--)
           if (d2 [k] [i] != d)
               goto Fail;

   count += 1;
   for (d1 [0] = 5.6, i = 1; i < 8; i++)       /* assign & check singly-    */
       d1 [i] = d1 [i-1] + 1.0;                /*  dimensioned double array */
   for (d = 12.6, k = 7; k >= 0; k--)
       if ( (fabs (d1 [k] - d--)) > 0.0001 )
           goto Fail;

   count += 1;
   for (e = 96e-75, i = 0; i < 7; i++) /* assign & check multiply-dimensioned */
       for (j = 0; j < 3; j++)         /*   extended array                    */
           e2 [i] [j] = e;
   for (i = 0; i < 7; i++)
       for (j = 0; j < 3; j++)
           if ( (fabs (e2 [i] [j] - 96.0e-75)) > 0.0001 )
               goto Fail;

   count += 1;
   for (k = 8; k >= 0; k--)            /* assign & check singly-dimensioned */
       e1 [k] = 0;                     /*   extended array                  */
   for (e = 0.000, i = 0; i < 9; i++)
       if (e1 [i] != e)
           goto Fail;

   count += 1;
   for (i = 0; i < 10; i++)            /* assign & check singly-dimensioned */
     {                                 /*   array of structures             */
       s1 [i].a = i;
       s1 [i].f = (float) i * 2.0;
     }
   for (f = 18.0, i = 9; i >= 0; i--)
     {
       if ((s1 [i].a != i) || (fabs (s1 [i].f - f) > 0.0001) )
           goto Fail;
       f -= 2.0;
     }

   for (n = 32766, f = 29.8E10, i = 0; i < 5; i++) /* assign & check multipy- */
       for (j = 0; j < 4; j++)                     /*   dimensioned array of  */
         {                                         /*   structures            */
           s2 [i] [j].a = n--;
           s2 [i] [j].f = f;
         }

   count += 1;
   for (n = 32746, k = 4; k >= 0; k--)
       for (j = 3; j >= 0; j--)
           if ((s2 [k] [j].a != ++n) || (fabs (s2 [k] [j].f - f) > 0.0001) )
               goto Fail;

   count += 1;
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

   count += 1;
   for (n = 5; n >= 0; n--)                        /* assign & check singly- */
       C1 [n] = black;                             /*   dimensioned array of */
   for (k = 0; k < 6; k++)                         /*   enumerations         */
       if (C1 [k] != 1)
           goto Fail;

   count += 1;
   for (i = 0; i < 3; i++)                       /* assign & check multiply- */
       for (j = 0; j < 3; j++)                   /*   dimensioned array of   */
           u2 [i] [j].first = j;                 /*   unions                 */
   for (n = 2; n >= 0; n--)
       if (u2 [n] [0].first != 0)
           goto Fail;

   count += 1;
   for (n = 2; n >= 0; n--)
       if (u2 [n] [1].first != 1)
           goto Fail;

   count += 1;
   for (n = 2; n >= 0; n--)
       if (u2 [n] [2].first != 2)
           goto Fail;

   count += 1;
   for (L = 2147483646, i = 0; i < 3; i++)
       for (j = 0; j < 3; j++)
           u2 [i] [j].second = L--;
   for (L = 2147483637, k = 2; k >= 0; k--)
       for (n = 2; n >= 0; n--)
           if (u2 [k] [n].second != ++L)
               goto Fail;

   count += 1;
   for (i = 0; i < 12; i++)            /* assign & check singly-dimensioned */
       u1 [i].first = i;               /*   array of unions                 */
   for (k = 11; k >= 0; k--)
       if (u1 [k].first != k)
           goto Fail;

   count += 1;
   for (L = 32767, j = 0; j < 12; j++)
       u1 [j].second = L++;
   for (L = 32778, n = 11; n >= 0; n--)
       if (u1 [n].second != L--)
           goto Fail;

   return (1);

Fail:
   printf ("count = %d\n", count);
   return (0);
  }
