/* Conformance Test 2.7.1.7:  Test unsigned integer constants */
main ()
  {
   unsigned           a;
   unsigned int       b;
   unsigned short     c;
   unsigned short int d;

   /* Test unsigned maxint for Apple IIGS */
   a = b = 0xFFFF;
   c = 0177777;
   d = 65535u;
   if ((a != c) || (b != d))
       goto Fail;

   /* Test zero */
   a = 0;
   b = 0000;
   c = 0x0000;
   d = a;
   if ((a != 0) || (b != 0) || (c != 0) || (d != 0))
       goto Fail;

   /* Test intermediate values */
   a = 0x9AbC;
   b = 39612;
   c = d = 0115274;
   if ((a != b) || (b != d))
       goto Fail;

   a = 32767;
   b = c = 077777;
   d = 0X7fFfU;
   if ((a != b) || (c != d))
       goto Fail;

   /* Test octal digit string with 255 characters */
   a = \
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000007;

   /* Test hexadecimal digit string with 255 characters */
   a = \
0x0000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000\
0000000000000000000000000324;
   if (a != 0x324)
       goto Fail;

   printf ("Passed Conformance Test 2.7.1.7\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.1.7\n");
  }
