/* Conformance Test 2.1.0.2:  Verification of ANSI C trigraphs */

??=define ten 10                       /* ??= is '#' */

main ()
  ??<                                  /* ??< is '{' */
   int  i;
   char a, b??(10??) = "abc";          /* ??( is '[' */
                                       /* ??) is ']' */

   if (ten != 10)
       goto Fail;

   if ((strcmp (b, "abc")) != 0)
       goto Fail;

   a = '??/n';                         /* ??/ is '\' */
   if (a != 0x0A)
       goto Fail;

   i = 5 ??/
       * 8;

   i = 0x7F ??' 0x03;                  /* ??' is '^', XOR */
   if (i != 0x7C)
       goto Fail;

   i = 0x45 ??! 0x03;                  /* ??! is '|', OR  */
   if (i != 0x47)
       goto Fail;

   i = ??-i;                           /* ??- is '~', bitwise negation */
   if (i != 0xFFB8)
       goto Fail;

   printf ("Passed Conformance Test 2.1.0.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.1.0.2\n");
  ??>                                  /* ??> is '}' */
