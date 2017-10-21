/* Deviance Test 8.8.0.1:  Ensure illegal break and continue statements are  */
/*                         detected                                          */

#include <stdio.h>

main ()
  {
   break;                /* break outside of while, do, for, switch statement */
   continue;             /* continue outside of while, do, for statement      */

   switch (1)
     {
       case 1: continue;
     }

   printf ("Failed Deviance Test 8.8.0.1\n");
  }
