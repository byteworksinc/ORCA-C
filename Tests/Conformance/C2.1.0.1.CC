/* Conformance Test 2.1.0.1:  Verification of character set */
main ()
  {
   char string1 [] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
   char string2 [] = "abcdefghijklmnopqrstuvwxyz";
   char string3 [] = "0123456789";
   char string4 [] = " !\"#$%&\'()*+,-./";
   char string5 [] = ":;<=>?@";
   char string6 [] = "[\\]^_";
   char string7 [] = "{|}~";
   char string8 [] = "\b\t\v\f\r\a\?";
   int  encode, i;

   /* Create a string variable from the required characters and check */
   /* its contents against the ASCII encodings for the characters.    */
   for (i = 0, encode = 0x41; i < 26; i++, encode++)
       if (string1 [i] != encode)
           goto Fail;

   for (i = 0, encode = 0x61; i < 26; i++, encode++)
       if (string2 [i] != encode)
           goto Fail;

   for (i = 0, encode = 0x30; i < 10; i++, encode++)
       if (string3 [i] != encode)
           goto Fail;

   for (i = 0, encode = 0x20; i < 15; i++, encode++)
       if (string4 [i] != encode)
           goto Fail;

   for (i = 0, encode = 0x3A; i < 7; i++, encode++)
       if (string5 [i] != encode)
           goto Fail;

   for (i = 0, encode = 0x5B; i < 5; i++, encode++)
       if (string6 [i] != encode)
           goto Fail;

   for (i = 0, encode = 0x7B; i < 4; i++, encode++)
       if (string7 [i] != encode)
           goto Fail;

   if (string8 [0] != 0x08)
       goto Fail;
   if (string8 [1] != 0x09)
       goto Fail;
   if (string8 [2] != 0x0B)
       goto Fail;
   if (string8 [3] != 0x0C)
       goto Fail;
   if (string8 [4] != 0x0D)
       goto Fail;
   if (string8 [5] != 0x07)
       goto Fail;
   if (string8 [6] != 0x3F)
       goto Fail;

   printf ("Passed Conformance Test 2.1.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.1.0.1\n");
 }
