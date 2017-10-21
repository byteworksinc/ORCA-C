/* Conformance Test 2.7.1.6:  Test hexadecimal long integer constants */
main ()
  {
   long     a;
   long int b;

   /* Test maxlong for Apple IIGS */
   a = 0x7FFFFFFF;
   b = 0X7fffFFff;
   if ((a != 2147483647) || (b != 2147483647))
       goto Fail;

   /* Test minlong for Apple IIGS */
   a = 0X80000000;
   b = 0x80000000;
   if ((a != -(2147483647 + 1)) || (b != -(2147483647 + 1)))
       goto Fail;

   /* Test zero */
   a = 0x0;
   b = 0X00000000;
   if ((a != 0) || (b != 0))
       goto Fail;

   /* Test positive intermediate values */
   a = 0x7ffFfFfE;
   b = 0X7FFFFFfE;
   if ((a != 2147483646) || (b != 2147483646))
       goto Fail;

   a = 0x7ffFl;
   b = 0X7FFFL;
   if ((a != 32767) || (b != 32767))
       goto Fail;

   /* Test hexadecimal digit string with 255 characters */
   a = \
0X0000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000078A;
   if (a != 0x78A)
       goto Fail;

   printf ("Passed Conformance Test 2.7.1.6\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.1.6\n");
  }
