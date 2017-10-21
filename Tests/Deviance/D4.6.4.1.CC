/* Deviance Test 4.6.4.1:  Ensure illegal array initializations are detected */

static int i1 [3] = { 1, 2, 3, 4 };                    /* too many elements */
static long L1 [4] = { 1, 2, 3, 4, 5, 5, 7 };
static double d1 [3] = { 1.0, 2.0, 3.0, 4.0 };
static struct S1 { int i; float f; } s1 [2] = { {2, 1.0}, {3, 2.0},
                                                {4, 3.0}, {5, 4.0} };

char ch1 [2] = "oh, what a beautiful baby!!";
comp c1 [3] = { 1, 2, 3, 4, 5, 6 };
float f1 [1] = { 0, 0, 0, 0, 0, 0 };

int   i2 = 3;
float f2 = 3.0;

                                                       /* non-constant values */
static short i3 [] = { i2 * 2, i2 / 2 };
static double d3 [3] = { 3.0, (double) f2 };
static struct S1 s2 [2] = { i3 [0], f2 };

unsigned int i4 [2] = { i3 [1], i2 };
unsigned long L2 [4] = { (unsigned long) f2 + 3 };

main ()
  {
   int i5 [7] = { 14, 15, 16, 17, 18, 19, 20, 21 };    /* too many elements */
   float f5 [3] = { 1.1, 1.1, 1.1, 1.1, 4.4 };
   char ch [5] = "abcde";                              /* no room for ending */
                                                       /*   null             */

   double d5 [3] = { (double) (i2 * 2.3) };            /* non-constant values */
   struct S1 s5 [2] = { i2 - (i2 + 2), f2 / 7.2 };

   printf ("Failed Deviance Test 4.6.4.1\n");
  }
