/* Deviance Test 8.7.0.1:  Ensure illegal switch statements are detected */

#include <stdio.h>

main ()
  {
   int i = 3, j = 4;
   unsigned short s = 7;

   switch 3                                /* omit switch expr's () */
     default:  ;

   switch (i)                              /* non-constant case expressions */
     {
       case i * j: break;
       case j:     break;
     }

   switch (j)                              /* omit case expression */
       case:   break;

   switch (i)                              /* non-unique case expressions */
     {
       case 3:     break;
       case 4:     break;
       default:    break;
       case 3:     break;
     }

   switch (s)                              /* case expression of different  */
     {                                     /*   type than switch expression */
       case -3:    break;
       case -88:   break;
     }

   switch (i)                              /* only 1 default label allowed */
     {
       case 1:     break;
       default:    break;
       case 2: default:
                   break;
     }

   case 22:        i = 3;          /* case label only allowed in switch body */
   default:        j = 90;         /* default label only allowed in switch   */

   switch (76.443);                /* switch expr can't be floating point typ*/
   switch (&j + 1);                /* switch expr can't be pointer type      */

   printf ("Failed Deviance Test 8.7.0.1\n");
  }
