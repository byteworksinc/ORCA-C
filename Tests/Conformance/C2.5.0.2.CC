/* Conformance Test 2.5.0.2:  Test characters comprising function identifiers */
main ()
  {
   extern double i_______________000000000000000000000000000000__________ ();

   extern float  \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210____________01234567899876543210 ();

   extern long   \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210____________0123456789987654321 ();

   double k;
   float  t, realNum;
   long   m;

   k = i_______________000000000000000000000000000000__________ ();
   if (k != 1.0e0)
       goto Fail;

   t = \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210____________01234567899876543210 ();
   realNum = 2.5e1;
   if (realNum != 2.5e1)
       goto Fail;

   m = \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210____________0123456789987654321 (4, 5);
   if (m != 20L)
       goto Fail;

   printf ("Passed Conformance Test 2.5.0.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.5.0.2\n");
 }

/************************************************************************/

double i_______________000000000000000000000000000000__________ ()
  {
   return (1.);
  }


/************************************************************************/

float  \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210____________01234567899876543210 ()
  {
   return (25.0);
  }

/************************************************************************/

long   \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210____________0123456789987654321

   ( _a_very_long_long_long_long_long_000000088888888888_parameter,
   ____________________________________another_long_parameter )

   int _a_very_long_long_long_long_long_000000088888888888_parameter,
       ____________________________________another_long_parameter;

  {
   return ( \
   _a_very_long_long_long_long_long_000000088888888888_parameter * \
   ____________________________________another_long_parameter );
  }
