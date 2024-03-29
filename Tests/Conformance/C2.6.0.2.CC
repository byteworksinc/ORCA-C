/* Conformance Test 2.6.0.2:  Check if reserved words can be used as */
/* preprocessor macro names                                          */

#include <stdlib.h>

int printf(const char *, ...);

#define    goto        1
#define    if          2
#define    return      3

int main (void)
  {

   while (goto != 1)
     {
       printf ("Failed Conformance Test 2.6.0.2\n");
       exit (1);
     }

   while (if != 2)
     {
       printf ("Failed Conformance Test 2.6.0.2\n");
       exit (1);
     }

   while (return != 3)
     {
       printf ("Failed Conformance Test 2.6.0.2\n");
       exit (1);
     }

   printf ("Passed Conformance Test 2.6.0.2\n");
  }
