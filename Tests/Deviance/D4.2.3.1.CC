/* Deviance Test 4.2.3.1:  Ensure illegal forward references are detected */

main ()
  {
   int  i;
   aPtr x;                        /* forward reference to user-defined type   */
   struct complex y;              /* forward reference to type tag            */
   struct complex { float real;
                    float imag; };

   i = F1 ('a');                  /* forward reference to prototyped function */
   j = 3 * 7;                     /* forward reference to variable            */
   v.one = 1;                     /* forward reference to component           */
  }

/*****************************************************************************/

int F1 (char ch)
  {
   return (int) ch;
  }
