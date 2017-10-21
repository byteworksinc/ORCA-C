/* Conformance Test 2.7.1.1:  Test decimal integer constants */
main ()
  {
   int   a;
   short b;

   /* Test maxint for Apple IIGS */
   a = 32767;
   b = a;
   if ((a != 32767) || (b != 32767))
       goto Fail;

   /* Test minint for Apple IIGS */
   a = -32768;
   b = -32768;
   if ((a != -32768) || (b != -32768))
       goto Fail;

   /* Test zero */
   a = 0;
   b = 0;
   if ((a != 0) || (b != 0))
       goto Fail;

   /* Test positive intermediate values */
   a = 32766;
   b = a;
   if ((a != 32766) || (b != 32766))
       goto Fail;

   /* Test negative intermediate values */
   b = -32767;
   a = b;
   if ((a != -32767) || (b != -32767))
       goto Fail;

   printf ("Passed Conformance Test 2.7.1.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.1.1\n");
  }
