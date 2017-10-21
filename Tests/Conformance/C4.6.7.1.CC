/* Conformance Test 4.6.7.1:  Verification of union initialization */

union U1 { int   i;
           long  L;
           float f; };

union U1 u1 = { 3 };
static union U1 u2 = 5;

main ()
  {
   auto union U1 u3 = { 32767 };

   if (u1.i != 3)
       goto Fail;

   if (u2.i != 5)
       goto Fail;

   if (u3.i != 32767)
       goto Fail;

   printf ("Passed Conformance Test 4.6.7.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.6.7.1\n");
  }
