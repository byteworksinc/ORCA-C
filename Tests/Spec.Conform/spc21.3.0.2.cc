/*                                                                            */
/* Special Conformance Test 21.3.0.2:  Verification of _exit function         */
/*                                                                            */
/* The tester should verify that the program halts and that the {status}      */
/* shell variable is set to 10 upon completion of the program.  No messages   */
/* should be printed by any of the functions registered with atexit.          */
/*                                                                            */

#include <stdlib.h>


/******************************************************************************/

void F1 ()
  {
   printf ("Return from function 1\n");
  }

/******************************************************************************/

void F2 ()
  {
   printf ("Return from function 2\n");
  }

/******************************************************************************/

void F3 ()
  {
   printf ("Return from function 3\n");
  }

/******************************************************************************/


main ()
  {
   int i;

   i = atexit (F3);
   if (i != 0)
       goto Fail;

   i = atexit (F2);
   if (i != 0)
       goto Fail;

   i = atexit (F1);
   if (i != 0)
       goto Fail;

   _exit (10);

Fail:
   printf ("Failure of atexit function in Special Conformance Test 21.3.0.2\n");
  }
