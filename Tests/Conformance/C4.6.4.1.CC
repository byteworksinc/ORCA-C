/* Conformance Test 4.6.4.1:  Test initialization of static and extern arrays */

#include <math.h>
#include <stdio.h>

/* Check size supplied by compiler */

static int i1 [] = { 1, 2, 3 };
static int i2 [] [2] = { {4, 5}, {6, 7}, {8, 9} };

static extended e1 [] = { 1.0, 2.0, 3.0, 4.0 };
static extended e2 [] [3] = { {1.1, 1.2, 1.3}, {2.2, 2.3, 2.4} };

char ch1 [] = "Now is the time";
char ch2 [] [20] = { "for all good people", "to come to the aid " };

double d1 [] = { 5.4, 5.5, 5.6, 5.7 };
double d2 [] [2] [3] = { { {6.6, 6.7, 6.8},  {7.7, 7.8, 7.9} },
                         { {8.8, 8.9, 9.0},  {3.3, 3.4, 3.5} },
                         { {4.4, 4.5, 4.6},  {5.5, 5.6, 5.7} } };

/* Ensure that missing values are zeroed */

static long L1 [4] = { 2, 3 };
extended e3 [5] = { 1.1, 2.2, 3.3 };

static struct S1 { int   x, y, z;
                   float a, b, c; } s1 [3] = { { 1, 2, 3, 2.0, 3.0, 4.0 } };
struct S2 { char   ch1, ch2;
            double d1, d2; } s2 [4] = { {'a', 'b', 3.3, 4.4},
                                        {'l', 'm', 3.5, 4.6} };

main ()
  {
   int i, j, k, m;                     /* local variables */
   double   d3;
   extended e4;

   /* Check sizes of arrays */
   if ((sizeof (i1) != 6) || (sizeof (i2) != 12) || (sizeof (e1) != 40) ||
       (sizeof (e2) != 60) || (sizeof (ch1) != 16) || (sizeof (ch2) != 40))
       goto Fail;

   if ((sizeof (d1) != 32) || (sizeof (d2) != 144) || (sizeof (L1) != 16) ||
       (sizeof (e3) != 50) || (sizeof (s1) != 54) || (sizeof (s2) != 72))
       goto Fail;

   /* Check array contents */

   for (i = 0; i < 3; i++)                                     /* i1 */
       if (i1 [i] != i + 1)
           goto Fail;

   for (i = 0, k = 4; i < 3; i++)                              /* i2 */
       for (j = 0; j < 2; j++)
         {
           if (i2 [i] [j] != k)
               goto Fail;
           k += 1;
         }

   for (i = 0, e4 = 1.0; i < 4; i++)                           /* e1 */
     {
       if (e1 [i] != e4)
           goto Fail;
       e4 += 1.0;
     }

   for (e4 = 1.1, i = 0; i < 3; i++)                           /* e2 */
     {
       if (fabs(e2 [0] [i] - e4) > 0.00001)
           goto Fail;
       e4 += 0.1;
     }

   for (e4 = 2.2, i = 0; i < 3; i++)
     {
       if (fabs(e2 [1] [i] - e4) > 0.00001)
           goto Fail;
       e4 += 0.1;
     }

   if (strcmp (ch1, "Now is the time"))                        /* ch1 */
       goto Fail;

   if ((strcmp (&ch2 [1], "to come to the aid ")) ||           /* ch2 */
       (strcmp (&ch2 [0], "for all good people")))
       goto Fail;

   for (d3 = 5.4, i = 0; i < 4; i++)                           /* d1 */
     {
       if (fabs(d1 [i] - d3) > 0.00001)
           goto Fail;
       d3 += 0.1;
     }

   for (d3 = 6.6, i = 0; i < 3; i++)       /* 0,0,0-2 of d2 */     /* d2 */
     {
       if (fabs(d2 [0] [0] [i] - d3) > 0.00001)
           goto Fail;
       d3 += 0.1;
     }

   for (d3 = 7.7, i = 0; i < 3; i++)       /* 0,1,0-2 of d2 */
     {
       if (fabs(d2 [0] [1] [i] - d3) > 0.00001)
           goto Fail;
       d3 += 0.1;
     }

   for (d3 = 8.8, i = 0; i < 3; i++)       /* 1,0,0-2 of d2 */
     {
       if (fabs(d2 [1] [0] [i] - d3) > 0.00001)
           goto Fail;
       d3 += 0.1;
     }

   for (d3 = 3.3, i = 0; i < 3; i++)       /* 1,1,0-2 of d2 */
     {
       if (fabs(d2 [1] [1] [i] - d3) > 0.00001)
           goto Fail;
       d3 += 0.1;
     }

   for (d3 = 4.4, i = 0; i < 3; i++)       /* 2,0,0-2 of d2 */
     {
       if (fabs(d2 [2] [0] [i] - d3) > 0.00001)
           goto Fail;
       d3 += 0.1;
     }

   for (d3 = 5.5, i = 0; i < 3; i++)       /* 2,1,0-2 of d2 */
     {
       if (fabs(d2 [2] [1] [i] - d3) > 0.00001)
           goto Fail;
       d3 += 0.1;
     }

   /* L1 */

   if ((L1 [0] != 2) || (L1 [1] != 3) || (L1 [2] != 0) || (L1 [3] != 0))
       goto Fail;

   /* e3 */

   if ((fabs(e3 [0] - 1.1) > 0.00001) || (fabs(e3 [1] - 2.2) > 0.00001) ||
      (fabs(e3 [2] - 3.3) > 0.00001) || (fabs(e3 [3]) > 0.00001) ||
      (fabs(e3 [4] ) > 0.00001))
       goto Fail;

   /* s1 */

   if ((s1 [0].x != 1) || (s1 [0].y != 2) || (s1 [0].z != 3) ||
       (fabs(s1 [0].a - 2.0) > 0.00001) || (fabs(s1 [0].b - 3.0) > 0.00001) ||
       (fabs(s1 [0].c - 4.0) > 0.00001))
       goto Fail;

   for (i = 1; i < 3; i++)
       if ((s1 [i].x != 0) || (s1 [i].y != 0) || (s1 [i].z != 0) ||
           (s1 [i].a != 0.0) || (s1 [i].b != 0.0) || (s1 [i].c != 0.0))
       goto Fail;

   /* s2 */

   if ((s2 [0].ch1 != 'a') || (s2 [0].ch2 != 'b') ||
       (s2 [1].ch1 != 'l') || (s2 [1].ch2 != 'm'))
       goto Fail;

   if ((fabs(s2 [0].d1 - 3.3) > 0.00001) || (fabs(s2 [0].d2 - 4.4) > 0.00001) ||
       (fabs(s2 [1].d1 - 3.5) > 0.00001) || (fabs(s2 [1].d2 - 4.6) > 0.00001))
       goto Fail;

   for (i = 2; i < 4; i++)
       if ((s2 [i].ch1 != 0) || (s2 [i].ch2 != 0) ||
           (s2 [i].d1 != 0.0) || (s2 [i].d2 != 0.0))
       goto Fail;

   printf ("Passed Conformance Test 4.6.4.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.6.4.1\n");
  }
