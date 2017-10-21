/* Conformance Test 2.4.0.1:  Ensure =+ is assigment followed by unary plus */
main ()
  {
   int a;

   a = 3;
   a =+ 2;
   if (a == 2)
       printf ("Passed Conformance Test 2.4.0.1\n");
   else
       printf ("Failed Conformance Test 2.4.0.1\n");
  }
