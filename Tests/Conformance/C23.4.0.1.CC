/* Conformance Test 23.4.0.1:  Verification of startdesk, enddesk functions */

#include <orca.h>

main ()
  {
   startdesk (640);
   if ( toolerror () )
       goto Fail;
   enddesk ();
   if ( toolerror () )
       goto Fail;

   printf ("Passed Conformance Test 23.4.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 23.4.0.1\n");
  }
