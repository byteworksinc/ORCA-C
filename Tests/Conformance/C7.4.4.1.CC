/* Conformance Test 7.4.4.1:  Verification of postincrement operator */

#include <math.h>
#include <stdio.h>

main ()
  {
   int  i  = 5, j;
   long L  = 32777;
   char ch = 'y';

   unsigned int  ui  = 65534;
   unsigned long ul  = 0x7FFFFFFF;
   unsigned char uch = 0x80;

   comp     c = 2147483646;
   float    f = 3.5;
   double   d = 87.65;
   extended e = 92.33;

   struct st {int i,j;} s[2];

   i++;
   L++;
   ch++;
   ui++;
   ul++;
   uch++;
   c++;
   f++;
   d++;
   e++;
   if ((i != 6) || (L != 32778) || (ch != 'z') || (ui != 65535) ||
       (ul != 0x80000000) || (uch != 0x81) || (c != 2147483647) ||
       (fabs(f - 4.5) > 0.00001) || (fabs(d - 88.65) > 0.00001) ||
       (fabs(e - 93.33) > 0.00001))
       goto Fail;

   i = 1;
   s[1].j = 3;
   j = s[i].j++;
   if ((j != 3) || (s[i].j != 4))
      goto Fail;

   printf ("Passed Conformance Test 7.4.4.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.4.4.1\n");
  }
