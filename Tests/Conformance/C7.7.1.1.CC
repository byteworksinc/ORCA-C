/* Conformance Test 7.7.1.1:  Verification of logical AND operator */

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


   /* Perform logical ANDs; test expected results.  Left-to-right evaluation */
   /* guaranteed.                                                            */

   j = i [0] && i [2];    k = L && c;    m = 0 && uch++;    n = a && ch--;
   if ((j != 1) || (k != 1) || (m != 0) || (n != 0) || (uch != 8) ||
       (ch != '!'))
       goto Fail;


  j = f && (!d);    k = --e && ++L;   m = d && f;    n = 0 && f--;
  if ((j != 0) || (k != 1) || (m != 1) || (n != 0) ||
      (fabs(e - 91.33) > 0.00001) || (L != 32778) || (fabs(f - 3.5) > 0.00001))
       goto Fail;


  j = i1ptr && i2ptr;    k = 0 && (--i2ptr);
  m = i2ptr && i1ptr++;  n = i2ptr-- && 0;
  if ((j != 1) || (k != 0) || (m != 1) || (n != 0) || (*i1ptr != 6) ||
      (*i2ptr != 6))
       goto Fail;


   printf ("Passed Conformance Test 7.7.1.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.7.1.1\n");
  }
