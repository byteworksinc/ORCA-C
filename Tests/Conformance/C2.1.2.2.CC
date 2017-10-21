/* Conformance Test 2.1.2.2:  Ensure '\' can be used to continue source lines */
main ()
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
   return;

Fail:
   printf ("Failed Conformance Test 2.1.2.2\n");
 }
