/* Conformance Test 2.7.1.2:  Test octal integer constants */
main ()
  {
   int   a;
   short b;

   /* Test maxint for Apple IIGS */
   a = 077777;
   b = a;
   if ((a != 32767) || (b != 32767))
       goto Fail;

   /* Test minint for Apple IIGS */
   a = -0100000;
   b = a;
   if ((a != -32768) || (b != -32768))
       goto Fail;

   /* Test zero */
   a = 0;
   b = a;
   if ((a != 0) || (b != 0))
       goto Fail;

   /* Test positive intermediate values */
   a = 077776;
   b = a;
   if ((a != 32766) || (b != 32766))
       goto Fail;

   /* Test negative intermediate values */
   b = -077777;
   a = b;
   if ((a != -32767) || (b != -32767))
       goto Fail;

   /* Test octal digit string with 255 characters */
   a = \
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000007;

   printf ("Passed Conformance Test 2.7.1.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.1.2\n");
  }
