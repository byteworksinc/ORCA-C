/* Conformance Test 24.0.1:  Verification of floating-point expressions for */
/*                           68881 card                                     */

#define SLOT    3
#define __FPE__ SLOT
#pragma float   1       SLOT

#include <stdio.h>
#include <math.h>

float    f = 3.5;
double   d = 87.65;
extended e = 92.33;

int i, j, k, m;

int sub1(void)

{
   f++; d++; e++;                                       /* test postincrement */
   if ((fabs(f - 4.5) > 0.00001) || (fabs(d - 88.65) > 0.00001) ||
       (fabs(e - 93.33) > 0.00001))
       goto Fail;

   f--; d--; e--;                                       /* test postdecrement */
   if ((fabs(f - 3.5) > 0.00001) || (fabs(d - 87.65) > 0.00001) ||
       (fabs(e - 92.33) > 0.00001))
       goto Fail;

   f = f * 2.4;   d = d * (-7.2);   e = e * 9.22;           /* multiplication */
   if ((fabs(f - 8.4) > 0.00001) || (fabs(d - (-631.08)) > 0.00001) ||
       (fabs(e - 851.2826) > 0.00001))
       goto Fail;

   f = f / 2.0;   d = d / -3.0;   e = e / 0.2;                    /* division */
   if ((fabs(f - 4.2) > 0.00001) || (fabs(d - 210.36) > 0.00001) ||
       (fabs(e - 4256.413) > 0.00001))
       goto Fail;

   i = f < d;  j = d <= e;  k = e > f;  m = e >= e;   /* relational operators */
   if ((i != 1) || (j != 1) || (k != 1) || (m != 1))
       goto Fail;

   return 0;

Fail:
   return 1;
}

int sub2(void)

{
   i = 0 && e--;  j = f && 0;  k = d++ && --f;        /* logical AND operator */
   if ((i != 0) || (j != 0) || (k != 1) || (fabs(e - 4256.413) > 0.00001) ||
       (fabs(d - 211.36) > 0.00001) || (fabs(f - 3.2) > 0.00001))
       goto Fail;

   i = 0 || e--;  j = f || 0;  k = d++ || --f;         /* logical OR operator */
   if ((i != 1) || (j != 1) || (k != 1) || (fabs(e - 4255.413) > 0.00001) ||
       (fabs(d - 212.36) > 0.00001) || (fabs(f - 3.2) > 0.00001))
       goto Fail;

   f = e ? 8 >> 1: d--;                             /* conditional expression */
   if ((fabs(f - 4.0) > 0.00001) || (fabs(d - 212.36) > 0.00001))
       goto Fail;

   return 0;

Fail:
   return 1;
}

int sub3(void)

{
   d += 5;  e -= 8.9;  f *= 3.0;                       /* compound assignment */
   if ((fabs(f - 12.0) > 0.00001) || (fabs(d - 217.36) > 0.00001) ||
       (fabs(e - 4246.513) > 0.00001))
       goto Fail;
   f /= -0.4;
   if (fabs(f - (-30.0)) > 0.00001)
       goto Fail;

   f = (e = ((extended) (long) (e * 2.0)), d--, d--);       /* comma operator */
   if ((fabs(f - 216.36) > 0.00001) || (fabs(d - 215.36) > 0.00001) ||
       (fabs(e - 8493.0) > 0.00001))
       goto Fail;

   return 0;

Fail:
   return 1;
}

main ()
  {
   if (sub1()) goto Fail;
   if (sub2()) goto Fail;
   if (sub3()) goto Fail;

   printf ("Passed Conformance Test 24.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 24.0.1\n");
  }
