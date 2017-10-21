/* Deviance Test 4.6.7.1: Ensure illegal initialization of unions is detected */

union U1 { int   i;
           long  L;
           char ch [5]; };

union U1 u1 = "hey, you!";           /* init. must be valid for only 1st type */
static union U1 u2 = &u1.i;

union U1 u3 = { 5, 6, "a", 2, 3 };   /* too many values */
static union U1 u4 = { 2, 4, 6.0 };


main ()
  {
   int i = 5;

   auto union U1 u5 = { "abb" };   /* init. must be valid for only 1st type */
   static union U1 u6 = { &i };
   union U1 u7 = { 5, 7, 8.8 };    /* too many values */

   printf ("Failed Deviance Test 4.6.7.1\n");
  }
