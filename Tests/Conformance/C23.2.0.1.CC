/* Conformance Test 23.2.0.1:  Make sure the rtl pragma works           */

#pragma rtl

#include <stdio.h>

extern pascal void SysIOStartup (void);
extern pascal void SysIOShutDown (void);

int main (void)
  {
   SysIOStartup();
   printf ("Passed Conformance Test 23.2.0.1\n");
   SysIOShutDown();
   return 0;
  }
