/* Conformance Test 21.4.0.1:  Verification of setjmp, longjmp functions */

#include <setjmp.h>

jmp_buf env;                       /* setjmp, longjmp environment array */


/*****************************************************************************/

void F1 (char ch)
  {
   if (ch == 'a')
       longjmp (env, 0);           /* not allowed to do this -- should */
   else                            /*   cause setjmp to return a 1     */
       longjmp (env, 2);
  }

/*****************************************************************************/

main ()
  {
   int i;


   i = setjmp (env);               /* initialize env to main's environment */
   if (i == 0)
       F1 ('a');

   else if (i == 1)                /* check second return from setjmp */
     {
       printf ("Passed Conformance Test 21.4.0.1\n");
       return;
     }

   else
       printf ("Failed Conformance Test 21.4.0.1\n");
  }
