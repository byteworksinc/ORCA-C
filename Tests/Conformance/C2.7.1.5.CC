/* Conformance Test 2.7.1.5:  Test octal long integer constants */
main ()
  {
   long     a;
   long int b;

   /* Test maxlong for Apple IIGS */
   a = 017777777777;
   b = a;
   if ((a != 2147483647) || (b != 2147483647))
       goto Fail;

   /* Test maximum 32-bit octal value */
   a = 037777777777;
   b = a;
   if ((a != 0xfFfFfFfF) || (b != 0XFFFFFFFF))
       goto Fail;

   /* Test zero */
   a = 000000000000L;
   b = 0l;
   if ((a != 0) || (b != 0))
       goto Fail;

   /* Test positive intermediate values */
   a = 017777777776;
   b = a;
   if ((a != 2147483646) || (b != 2147483646))
       goto Fail;

   a = 077777;
   b = a;
   if ((a != 32767) || (b != 0x7FFF))
       goto Fail;

   /* Test octal digit string with 255 characters */
   a = \
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000007;

   printf ("Passed Conformance Test 2.7.1.5\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.1.5\n");
  }
