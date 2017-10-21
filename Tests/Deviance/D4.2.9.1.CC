/* Deviance Test 4.2.9.1:  Ensure illegal scoping of extern variables is */
/*                         detected                                      */

double X;

main ()
  {
   int i;

   if (i - 1)                          /* variable E should not be visible */
     {                                 /*   in the else clause             */
       extern extended E;
       E = 5.7;
     }
   else
     {
       E = 1.0;
     }

   printf ("Failed Deviance Test 4.2.9.1\n");

   }

/*****************************************************************************/

double F1 (int x, int y)
  {
   int   x;                            /* both declarations are in error -- */
   float y;                            /*   cannot redefine function parms  */
  }
