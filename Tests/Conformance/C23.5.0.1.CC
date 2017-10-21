/* Conformance Test 23.5.0.1:  Verification of startgraph, endgraph functions */

#include <orca.h>

main ()
  {
   startgraph (640);
   if ( toolerror () )
       goto Fail;
   endgraph ();
   if ( toolerror () )
       goto Fail;

   printf ("Passed Conformance Test 23.5.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 23.5.0.1\n");
  }
