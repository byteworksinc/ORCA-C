/* Conformance Test 23.2.0.1:  Make sure the rtl pragma works           */

#pragma rtl

#include <stdio.h>

int main (void)
  {
   SYSIOSTARTUP();
   printf ("Passed Conformance Test 23.2.0.1\n");
   SYSIOSHUTDOWN();
   return;
  }
