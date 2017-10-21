/* Conformance Test 16.4.0.1: Verification of memset library function */

#include <stddef.h>
#include <string.h>
#include <stdlib.h>

main ()
  {
   char *rgn, *ptr1;


   rgn = (char *) malloc (1024);
   if (rgn == NULL)
       goto Fail1;

   ptr1 = (char *) memset (rgn, 'a', 1024);
   if (ptr1 != rgn)
       goto Fail;

   for (; rgn != ptr1; rgn++)
       if (*rgn != 'a')
           goto Fail;

   free (rgn);

   printf ("Passed Conformance Test 16.4.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 16.4.0.1\n");
   return;

Fail1:
   printf ("Unable to allocate memory for Conformance Test 16.4.0.1\n");
   return;
  }
