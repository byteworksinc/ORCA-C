/* Deviance Test 9.2.0.1:  Ensure attempt to return an array or function  */
/*                         from a function is detected                    */


#include <stdio.h>


/*****************************************************************************/

int ( g (float f) ) []         /* g is a func returning an array of integers */
  {
   printf ("This message should never appear\n");
  }

/*****************************************************************************/

void ( f (void) ) ()         /* f is a func returning a func returning void */
  {
   printf ("This message should never appear\n");
  }

/*****************************************************************************/


main ()
  {
   printf ("Failed Deviance Test 9.2.0.1\n");
  }
