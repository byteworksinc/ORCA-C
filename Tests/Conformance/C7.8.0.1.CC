/* Conformance Test 7.8.0.1:  Verification of conditional expressions */

#include <stdio.h>
#include <math.h>

main ()
  {
   int  i [3]  = { 5, 6, 7 }, *i1ptr = i, *i2ptr = &i [2], *i3ptr;
   long L  = 32777;
   char ch = '!';

   enum E { a, b, c };
   struct S { int i; float f ;} s1 = { 1, 1.0 }, s2 = { 2, 2.2 }, s3;

   unsigned int  ui  = 653;
   unsigned long ul  = 895;

   float    f = 3.5;
   double   d = 87.65;
   extended e = 92.33;


   /* Evaluate conditional expressions; check expected results.  Ensure */
   /* operation is right associative.                                   */

   e = f ? L * 2: ch ? d: ul ? s1.f + s2.i: ui;
   if (fabs(e - 65554.0) > 0.00001)
       goto Fail;

   i [1] = a ? *i1ptr * 2: (*i2ptr / 7);
   if ((i [0] != 5) || (i [1] != 1) || (i [2] != 7))
       goto Fail;

   s3 = i1ptr ? s1 : s2;
   if ((s3.i != 1) || (s3.f != 1.0))
       goto Fail;

   i3ptr = (L / 8) ? (i1ptr += 2): NULL;
   if ((*i3ptr != 7) || (i1ptr != &i [2]))
       goto Fail;


   printf ("Passed Conformance Test 7.8.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.8.0.1\n");
  }
