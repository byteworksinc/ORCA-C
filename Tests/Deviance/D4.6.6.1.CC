/* Deviance Test 4.6.6.1:  Ensure illegal initialization of structures is */
/*                         detected                                       */

struct S1 { int   i;
            float f; } s1 = { 3, 8.0, 'a' };           /* too many values */

struct S1 s2 = 2, 7.6;                         /* can't omit outer braces */

static struct S1 s3 = { 5, 5.0, 6.0, 77.77 };          /* too many values */
static struct S1 s4 = 0, 0.0;                  /* can't omit outer braces */

main ()
  {
   int   i = 8;
   float f = 3.5;

   auto struct S1 s1 = { i * 2, f };           /* can only use constants  */
   register struct S1 s2 = { s1.i, f / 3.0 };

   auto struct S1 s3 = { 4, 4, 5, };                   /* too many values */
   register struct S1 s4 = { 3, 2.0, 5.0E10 };

   auto struct S1 s5 = 6, 17.9;                /* can't omit outer braces */
   register struct S1 s6 = 77, 90.0;

   printf ("Failed Deviance Test 4.6.6.1\n");
  }
