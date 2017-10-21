/* Conformance Test 2.7.1.8:  Test unsigned long integer constants */
main ()
  {
   unsigned long     a;
   unsigned long int b;

   /* Test unsigned maxlong for Apple IIGS */
   a = 0xFFFFffff;
   b = 037777777777;
   if ((a != (4294967295ul)) || (b != (4294967295UL)))
       goto Fail;

   /* Test zero */
   a = 0;
   b = 0000;
   if ((a != 0) || (b != 0))
       goto Fail;

   /* Test intermediate values */
   a = 0x81347500;
   b = 020115072400;
   if ((a != 2167698688ul) || (b != 2167698688UL))
       goto Fail;

   a = 2147545424uL;
   b = 2147545424Ul;
   if ((a != 0x8000f150) || (b != 020000170520))
       goto Fail;

   /* Test octal digit string with 255 characters */
   a = \
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000007uL;
   if (a != 7)
       goto Fail;

   /* Test hexadecimal digit string with 255 characters */
   a = \
0x0000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
0000000000000000000000000271L;
   if (a != 0x271)
       goto Fail;

   printf ("Passed Conformance Test 2.7.1.8\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.1.8\n");
  }
