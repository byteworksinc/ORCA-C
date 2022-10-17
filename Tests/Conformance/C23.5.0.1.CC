/* Conformance Test 23.5.0.1:  Verification of startgraph, endgraph functions */

#include <orca.h>

int printf(const char *, ...);

int main (void)
  {
   startgraph (640);
   if ( toolerror () )
       goto Fail;
   endgraph ();
   if ( toolerror () )
       goto Fail;

   printf ("Passed Conformance Test 23.5.0.1\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 23.5.0.1\n");
  }
