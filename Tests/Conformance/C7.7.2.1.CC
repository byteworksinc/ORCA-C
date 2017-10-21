/* Conformance Test 7.7.2.1:  Verification of logical OR operator */

#include <stdio.h>
#include <math.h>

main ()
  {
   int  i [3]  = { 5, 6, 7 }, *i1ptr = i, *i2ptr = &i [2];
   int  j, k, m, n;
   long L  = 32777;
   char ch = '!';
   enum E { a, b, c };

   unsigned int  ui  = 653;
   unsigned long ul  = 895;
   unsigned char uch = 0x8;

   float    f = 3.5;
   double   d = 87.65;
   extended e = 92.33;


   /* Perform logical ORs; test expected results.  Left-to-right evaluation */
   /* guaranteed.                                                           */

   j = i [0] || i [2];    k = L || c;    m = 0 || uch++;    n = a || ch--;
   if ((j != 1) || (k != 1) || (m != 1) || (n != 1) || (uch != 9) ||
       (ch != ' '))
       goto Fail;


  j = (!f) || (!d);    k = --e || ++L;   m = d || f;    n = 0 || a;
  if ((j != 0) || (k != 1) || (m != 1) || (n != 0) ||
     (fabs(e - 91.33) > 0.00001) || (L != 32777))
       goto Fail;


  j = i1ptr || f;        k = 0 || (--i2ptr);
  m = d || i1ptr++;      n = i2ptr-- || 0;
  if ((j != 1) || (k != 1) || (m != 1) || (n != 1) || (*i1ptr != 5) ||
      (*i2ptr != 5))
       goto Fail;


   printf ("Passed Conformance Test 7.7.2.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.7.2.1\n");
  }
