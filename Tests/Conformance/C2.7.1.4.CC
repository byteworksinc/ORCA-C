/* Conformance Test 2.7.1.4:  Test decimal long integer constants */
main ()
  {
   long     a;
   long int b;

   /* Test maxlong for Apple IIGS */
   a = 2147483647;
   b = a;
   if ((a != 2147483647) || (b != 2147483647))
       goto Fail;

   /* Test zero */
   a = 0L;
   b = 0l;
   if ((a != 0) || (b != 0))
       goto Fail;

   /* Test positive intermediate values */
   a = 2147483646;
   b = a;
   if ((a != 2147483646) || (b != 2147483646))
       goto Fail;

   a = 32767L;
   b = a;
   if ((a != 32767) || (b != 0x7FFF))
       goto Fail;

   printf ("Passed Conformance Test 2.7.1.4\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.1.4\n");
  }
