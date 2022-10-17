/* Conformance Test 23.4.0.1:  Verification of startdesk, enddesk functions */

#include <orca.h>

int printf(const char *, ...);

int main (void)
  {
   startdesk (640);
   if ( toolerror () )
       goto Fail;
   enddesk ();
   if ( toolerror () )
       goto Fail;

   printf ("Passed Conformance Test 23.4.0.1\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 23.4.0.1\n");
  }
