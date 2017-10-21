/* Conformance test 2.2.0.3:  Comments in preprocessor lines */
#define ten /* ten:
                          one greater
                          than nine
               */  (2 * 5)
main ()
  {
   if (ten == 10)
     {
       printf ("Passed Conformance Test 2.2.0.3\n");
     }
   else
     {
       printf ("Failed Conformance Test 2.2.0.3\n");
     }
   }
