/* Conformance Test 7.6.4.1:  Verification of relational operators */

#include <stdio.h>

main ()
  {
   int  i [3]  = { 5, 6, 7 }, *i1ptr = i, *i2ptr = &i [2];
   int  j, k, m, n;
   long L  = 32777;
   char ch = '!';

   unsigned int  ui  = 653;
   unsigned long ul  = 895;
   unsigned char uch = 0x8;

   comp     c = 4294;
   float    f = 3.5;
   double   d = 87.65;
   extended e = 92.33;


   /* Compare integers and test expected results. */

   j = i [0] < i [2];    k = L <= c;    m = uch >= ul;    n = ch > ch;
   if ((j != 1) || (k != 0) || (m != 0) || (n != 0))
       goto Fail;


  /* Compare floating point values and test expected results. */

  j = f < d;    k = e <= e;    m = d > e;    n = e >= f;
  if ((j != 1) || (k != 1) || (m != 0) || (n != 1))
       goto Fail;


  /* Compare pointers and test expected results. */

  j = i1ptr > i2ptr;    k = i2ptr <= i1ptr;
  m = i2ptr > i1ptr;    n = i1ptr >= i2ptr;
  if ((j != 0) || (k != 0) || (m != 1) || (n != 0))
       goto Fail;


   printf ("Passed Conformance Test 7.6.4.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.6.4.1\n");
  }
