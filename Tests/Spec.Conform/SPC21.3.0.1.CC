/*                                                                            */
/* Special Conformance Test 21.3.0.1:  Verification of exit, atexit functions */
/*                                                                            */
/* The tester should verify that the sequence of messages "return from        */
/* function 1", "return from function 2", "return from function 3" are        */
/* displayed on the screen, and that the {status} shell variable is set to    */
/* 3 upon completion of the program.                                          */
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

   exit (3);

Fail:
   printf ("Failure of atexit function in Special Conformance Test 21.3.0.1\n");
  }
