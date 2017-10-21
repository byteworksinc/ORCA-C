/* Conformance Test 19.7.0.1:  Verification of rand, srand library functions */

#include <stdlib.h>

main ()
  {
   int i, j, array1 [20], array30 [20];

   for (i = 0; i < 20; i++)
     {
       j = rand ();
       if ((j < 0 ) || (j > 32767))
           goto Fail;
       array1 [i] = j;
     }

   srand (30);
   for (i = 0; i < 20; i++)
     {
       j = rand ();
       if ((j < 0 ) || (j > 32767))
           goto Fail;
       array30 [i] = j;
     }

   srand (1);
   for (i = 0; i < 20; i++)
     {
       j = rand ();
       if (j != array1 [i])
           goto Fail;
     }

   srand (30);
   for (i = 0; i < 20; i++)
     {
       j = rand ();
       if (j != array30 [i])
           goto Fail;
     }


   printf ("Passed Conformance Test 19.7.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 19.7.0.1\n");
  }
