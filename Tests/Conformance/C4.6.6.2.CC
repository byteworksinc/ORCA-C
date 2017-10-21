/* Conformance Test 4.6.6.2:  Verification of auto and register structure */
/*                            initialization                              */

#include <stdio.h>
#include <math.h>

struct S1 { int      i;
            char     ch;
            long     L;
            float    f;
            double   d;
            extended e;
            unsigned int bf1: 8; };

struct S2 { int      i1  [5];
            char     ch1 [10];
            long     L1  [3];
            float    f1  [4];
            double   d1  [3];
            extended e1  [3];
            unsigned int  ui [4];
            unsigned long ul [2]; };

struct S3 { struct S1 s1;
            struct S2 s2; };


main ()
  {
   int      i, j;
   long     k;
   float    f;
   double   d;
   extended e;
   unsigned int  ui;
   unsigned long ul;

/* Initialization of auto and register structures allowed; each variable  */
/* within the structure can only be set to a constant.                    */

   register struct S1 s1 = { 1, 'a', -2147483647, 4.3, 4.3e100, 4.3e300, 0xFF };

   register struct S2 s2 = { { 1, 2, 3, 4, 5 }, "an array ", { 8, 9, 10 },
                           { 5.1, 5.2, 5.3, 5.4 }, { 5.1e50, 5.2e50, 5.3e50 },
                           { 5.1e200, 5.2e200, 5.3e200 }, { 0xFFFF, 0xFFFE,
                           0xFFFD } };

   register struct S3 s3 = { { 9, 'd', 80000, 88.9, 88.99, 888.999, 0x33 },
                           { { 9, 8, 7, 6, 5 }, "ten chars",
                             { 32768, 32769, 32770 }, { 6.0, 7.0, 8.0, 9.0 },
                             { 66.0, 77.0, 88.0, }, { 666.0, 777.0 },
                             { 0x7FFF, } } };

   struct S1 s4 = { 32767, 'z', 32788, 17.0, 18.0, 19.0, 5 };

   struct S2 s5 = { { 10, 20, 30, 40, 50 }, "ORCA/C !!", { 4, 5, 6 },
                    { 45.0, 55.0, 65.0, 75.0 }, { 455.0, 555.0, 655.0 },
                    { 4555.0, 5555.0 } };

   struct S3 s6 = { { 7654, 'x', 65535, 876.0, 877.0, 878.0, 033 },
                  { { 10, 9, 8, 7, 6 }, "it's back", { 2000, 2001, 2002 },
                    { 7.7, 8.8, 9.9, 11.0 }, { 6.0, 6.0, 6.0 },
                    { 1.0, 1.3 }, { 0x7f, 0x80, 0x81, 0x82 },
                    { 0x01 } } };


   /* Check initialization of struct s1. */

   if ((s1.i != 1) || (s1.ch != 'a') || (s1.L != -2147483647)
      || (fabs(s1.f - 4.3) > 0.00001)
      || (fabs(s1.d - 4.3e100) > 1e95) || (s1.bf1 != 0xFFu))
       goto Fail;


   /* Check initialization of struct s2. */

   for (i = 0; i < 5; i++)
       if (s2.i1 [i] != i + 1)
           goto Fail;

   if (strcmp (s2.ch1, "an array "))
       goto Fail;

   for (k = 8, i = 0; i < 3; i++)
       if (s2.L1 [i] != k++)
           goto Fail;

   for (f = 5.1, i = 0; i < 4; i++)
     {
       if (fabs(s2.f1 [i] - f) > 0.00001)
           goto Fail;
       f += 0.1;
     }

   for (d = 5.1e50, i = 0; i < 3; i++)
     {
       if (fabs(s2.d1 [i] - d) > 1e45)
           goto Fail;
       d += 0.1e50;
     }

   for (e = 5.1e200, i = 0; i < 2; i++)
     {
       if (fabs(s2.e1 [i] - e) > 1e195)
           goto Fail;
       e += 0.1e200;
     }

   for (ui = 0xFFFF, i = 0; i < 3; i++)
       if (s2.ui [i] != ui--)
           goto Fail;

   if ((s2.ui [3] != 0) || (s2.ul [0] != 0) || (s2.ul [1] != 0))
       goto Fail;


   /* Check initialization of struct s3. */

   if ((s3.s1.i != 9) || (s3.s1.ch != 'd') || (s3.s1.L != 80000) ||
       (fabs(s3.s1.f - 88.9) > 0.0001) || (fabs(s3.s1.d - 88.99) > 0.0001) ||
       (fabs(s3.s1.e - 888.999) > 0.0001) ||
       (s3.s1.bf1 != 0x33))
       goto Fail;

   for (j = 9, i = 0; i < 5; i++)
       if (s3.s2.i1 [i] != j--)
           goto Fail;

   if (strcmp (s3.s2.ch1, "ten chars"))
       goto Fail;

   for (k = 32768, i = 0; i < 3; i++)
       if (s3.s2.L1 [i] != k++)
           goto Fail;

   for (f = 6.0, i = 0; i < 4; i++)
     {
       if (s3.s2.f1 [i] != f)
           goto Fail;
       f += 1.0;
     }

   for (d = 66.0, i = 0; i < 3; i++)
     {
       if (fabs(s3.s2.d1 [i] - d) > 0.0001)
           goto Fail;
       d += 11.0;
     }

   for (e = 666.0, i = 0; i < 2; i++)
     {
       if (fabs(s3.s2.e1 [i] - e) > 0.0001)
           goto Fail;
       e += 111.0;
     }

   if (s3.s2.ui [0] != 0x7FFF)
       goto Fail;

   for (i = 1; i < 4; i++)
       if (s3.s2.ui [i] != 0)
           goto Fail;

   for (i = 0; i < 2; i++)
       if (s3.s2.ul [i] != 0)
           goto Fail;


   /* Check initialization of struct s4. */

   if ((s4.i != 32767) || (s4.ch != 'z') || (s4.L != 32788) ||
       (fabs(s4.f - 17.0) > 0.00001) || (fabs(s4.d - 18.0) > 0.00001) ||
       (fabs(s4.e - 19.0) > 0.00001) || (s4.bf1 != 5))
       goto Fail;


   /* Check initialization of struct s5. */

   for (j = 10, i = 0; i < 5; i++)
     {
       if (s5.i1 [i] != j)
           goto Fail;
       j += 10;
     }

   if (strcmp (s5.ch1, "ORCA/C !!"))
       goto Fail;

   for (k = 4, i = 0; i < 3; i++)
       if (s5.L1 [i] != k++)
           goto Fail;

   for (f = 45.0, i = 0; i < 4; i++)
     {
       if (fabs(s5.f1 [i] - f) > 0.0001)
           goto Fail;
       f += 10.0;
     }

   for (d = 455.0, i = 0; i < 3; i++)
     {
       if (fabs(s5.d1 [i] - d) > 0.0001)
           goto Fail;
       d += 100.0;
     }

   for (e = 4555.0, i = 0; i < 2; i++)
     {
       if (fabs(s5.e1 [i] - e) > 0.01)
           goto Fail;
       e += 1000.0;
     }

   for (i = 0; i < 4; i++)
       if (s5.ui [i] != 0)
           goto Fail;

   for (i = 0; i < 2; i++)
       if (s5.ul [i] != 0)
           goto Fail;


   /* Check initialization of struct s6. */

   if ((s6.s1.i != 7654) || (s6.s1.ch != 'x') || (s6.s1.L != 65535) ||
       (fabs(s6.s1.f - 876.0) > 0.001) || (fabs(s6.s1.d - 877.0) > 0.001) ||
       (fabs(s6.s1.e - 878.0) > 0.001) || (s6.s1.bf1 != 27))
       goto Fail;

   for (j = 10, i = 0; i < 5; i++)
       if (s6.s2.i1 [i] != j--)
           goto Fail;

   if (strcmp (s6.s2.ch1, "it's back"))
       goto Fail;

   for (k = 2000, i = 0; i < 3; i++)
       if (s6.s2.L1 [i] != k++)
           goto Fail;

   for (f = 7.7, i = 0; i < 4; i++)
     {
       if (fabs(s6.s2.f1 [i] - f) > 0.00001)
           goto Fail;
       f += 1.1;
     }

   for (d = 6.0, i = 0; i < 3; i++)
       if (s6.s2.d1 [i] != d)
           goto Fail;

   if ((fabs(s6.s2.e1 [0] - 1.0) > 0.00001)
      || (fabs(s6.s2.e1 [1] - 1.3) > 0.00001))
       goto Fail;

   for (ui = 0x7F, i = 0; i < 4; i++)
       if (s6.s2.ui [i] != ui++)
           goto Fail;

   if ((s6.s2.ul [0] != 1) || (s6.s2.ul [1] != 0))
       goto Fail;


   printf ("Passed Conformance Test 4.6.6.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.6.6.2\n");
  }
