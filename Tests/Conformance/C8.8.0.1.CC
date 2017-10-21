/* Conformance Test 8.8.0.1:  Verification of break, continue statements */

#include <stdio.h>
#define  youStillCan  1

main ()
  {
   int F1 (int i, int j);
   int i = 65, j = 7, k;

   while (i > 0)                       /* test break, continue in while loop */
     {
       j++;
       if (j == 15)
           break;
       if (((i - j) == 57) || ((i - j) == 55) || ((i - j)  == 52))
           continue;
       i--;
     }
   if ((i != 60) || (j != 15))
       goto Fail;


   do                                  /* test break, continue in do loop */
     {
       i -= 2;
       if (((i / 2) == 29) || ((i / 2) == 27) || ((i / 2) == 25))
           continue;
       j -= 3;
       if (j < 2)
           break;
     }
   while (youStillCan);
   if ((i != 44) || (j != 0))
       goto Fail;


   for (k = 100; k > 0; k -= 5)        /* test break, continue in for loop */
     {
       if (k > 80)
           continue;
       if (k == 60)
           break;
       k -= 5;
       j += 2;
     }
   if ((j != 4) || (k != 60))
       goto Fail;


   while ( (i = F1 (k, j)) > 57)        /* test nested while, do, for, switch */
     {
       do
         {
           for (; i > 60; i -= 4)
             {
               i /= 4;
               switch (i)
                 {
                   case 17:    k -= 1;
                               break;

                   case 16:    j -= 2;
                               break;

                   default:    k -= 5;
                               break;
                 }
               if (k > 40)
                   continue;

             }  /* end for */

           j -= 2;
           if (j == 0)
               break;
         } while (1);

       if (k == 45)
           continue;
       k -= 3;
     }
   if ((k != 57) || (j != 0) || (i != 57))
       goto Fail;


   printf ("Passed Conformance Test 8.8.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 8.8.0.1\n");
  }


/****************************************************************************/

int F1 (int i, int j)
  {
   return i + j;
  }
