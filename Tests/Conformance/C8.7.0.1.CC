/* Conformance Test 8.7.0.1:  Verification of switch statement */

#include <stdio.h>


/****************************************************************************/

int F1 (int i)
  {
   switch (i)
     {
       case 1:     return 9;
       case 2:     return 99;
       case 3:     return 999;
       default:    return 9999;
     }
  }


/****************************************************************************/

main ()
  {
   char ch = 'd';
   int   i = 3;
   short s = 5;
   long  L = 0;
   unsigned int ui = 0x7F;
   enum Colors { red, black, gold, green } color = gold;


   switch (i * s)                      /* test "fall through" of case labels */
     {
       case 15:    ++L;

       case 1:     ++L;

       case 2:     ++L;

       default:    ++L;
     }
   if (L != 4)
       goto Fail;


   switch (ch >> i)                    /* test break out with goto statement */
     {
       case 1:     L = 1;

       case 2:     L = 2;

       case 12:    L = 12;
                   goto Out;

       default:    L = 0;
     }
Out:
   if (L != 12)
       goto Fail;


   switch (s)                          /* test break out with break statement */
     {
       case 1:     L = 1;

       case 2:     L = 2;

       case 3:     L = 3;

       case 4:     L = 4;

       case 5:     L = 5;
                   break;

       default:    L = 0;
     }
   if (L != 5)
       goto Fail;


   switch (F1 (i))                    /* test break out with return statement */
     {
       case 999:   L = 999;
                   break;
       default:    L = 0;
     }
   if (L != 999)
       goto Fail;


   switch (2)                          /* test no case labels equal switch */
     {                                 /*   expr and no default given      */
       case 0:     L = 0;
       case 1:     L = 1;
     }
   if (L != 999)
       goto Fail;


   switch (ui)                         /* multiple case labels + default on */
     {                                 /*   same statement                  */
       case 0x7c:  L = 0x7c;
                   break;

       case 0x7e: case 0x7F: case 0x80: default:
                   L = 0x80;
                   break;

       case 0x7D:  L = 0x7d;
                   break;
     }
   if (L != 128)
       goto Fail;

{
   enum Colors { red, black, gold, green } color = gold;
   switch (color)                      /* test nested switch statements */
     {
       case red:   switch (ui && i)
                     {
                       case 1:     L = 1;
                                   break;

                       case 0:     L = 0;
                                   break;
                     }
                   break;

       case black: switch (--i)
                     {
                       case 2:     L = 2;
                                   break;
                     }
                   break;

       case gold:  switch (color)
                     {
                       case gold:  L = (long) (color);
                     }
                   break;
     }
   if (L != 2)
       goto Fail;

}

   printf ("Passed Conformance Test 8.7.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 8.7.0.1\n");
  }
