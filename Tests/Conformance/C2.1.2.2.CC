/* Conformance Test 2.1.2.2:  Ensure '\' can be used to continue source lines */

int printf(const char *, ...);

int main (void)
  {
   int i;

   i = 5 * \
       6;
   if \
      (i != 30)
       goto Fail;

   i = 200 \
       - 7;
   if (\
       i != 193)
       goto Fail;

   i = \
       7 + 7;
   if (i\
         != 14)
       goto Fail;

   i \
     += 1;
   if (i !=\
            15)
       goto Fail;

   printf ("Passed Conformance Test 2.1.2.2\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 2.1.2.2\n");
 }
