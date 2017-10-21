/* Conformance Test 2.4.0.2:  Ensure =- is assigment followed by unary minus */
main ()
  {
   int a;

   a = 3;
   a =- 2;
   if (a == -2)
       printf ("Passed Conformance Test 2.4.0.2\n");
   else
       printf ("Failed Conformance Test 2.4.0.2\n");
  }
