/* Conformance Test 2.7.1.3:  Test hexadecimal integer constants */
main ()
  {
   int   a;
   short b;

   /* Test maxint for Apple IIGS */
   a = 0x7FFF;
   b = 0X7fff;
   if ((a != 32767) || (b != 32767))
       goto Fail;

   /* Test minint for Apple IIGS */
   a = -0X8000;
   b = -0x8000;
   if ((a != -32768) || (b != -32768))
       goto Fail;

   /* Test zero */
   a = 0x0;
   b = 0X00;
   if ((a != 0) || (b != 0))
       goto Fail;

   /* Test positive intermediate values */
   a = 0x7fFe;
   b = 0X7FfE;
   if ((a != 32766) || (b != 32766))
       goto Fail;

   /* Test negative intermediate values */
   b = -0x7fFF;
   a = -0X7FfF;
   if ((a != -32767) || (b != -32767))
       goto Fail;

   /* Test hexadecimal digit string with 255 characters */
   a = \
0x0000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
00000000000000000000000007FF;
   if (a != 0x7FF)
       goto Fail;

   printf ("Passed Conformance Test 2.7.1.3\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.1.3\n");
  }
