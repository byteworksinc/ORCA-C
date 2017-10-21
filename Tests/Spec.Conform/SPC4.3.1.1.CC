/* Special Conformance Test 4.3.1.1:  Ensure default storage class for    */
/*                                    functions declared at the head of a */
/*                                    block is extern                     */
/*                                                                        */
/* Other files needed: spc4311.cc   - separately compiled file containing */
/*                                    functions called in this file       */
/*                     spc4311.exec - EXEC file which separately compiles */
/*                                    links and runs the files comprising */
/*                                    this test                           */
/*                                                                        */

main ()
  {
   int    I1 (char ch);
   double D1 (float f);

   char  c;
   float f;

   c = I1 ('z');
   if (c != 'Z')
       goto Fail;

   f = D1 (8.9);
   if (f != 8.0)
       goto Fail;

   printf ("Passed Special Conformance Test 4.3.1.1\n");
   return;

Fail:
   printf ("Failed Special Conformance Test 4.3.1.1\n");
  }
