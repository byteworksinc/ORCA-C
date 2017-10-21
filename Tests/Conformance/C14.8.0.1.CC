/* Conformance Test 14.8.0.1:  Verification of toint function */

#include <ctype.h>
#include <stdio.h>

main ()
  {
   int   i, j;
   char  ch;
   unsigned char uc;


   /* toint:  returns 0-9 for char in ['0'..'9'] and 10-15 for char in */
   /*         ['a'..'f'] or ['A'..'F']                                 */

   for (uc = '0', i = 0; i < 10; uc++, i++)
     {
       j = toint (uc);
       if (j != i)
           goto Fail;
     }

   for (ch = 'A', i = 10; ch <= 'F'; ch++, i++)
     {
       j = toint (ch);
       if (j != i)
           goto Fail;
     }

   for (ch = 'a', i = 10; ch <= 'f'; ch++, i++)
     {
       j = toint (ch);
       if (j != i)
           goto Fail;
     }

   for (ch = 'G'; ch <= 'Z'; ch++)
     {
       j = toint (ch);
       if (j != EOF)
           goto Fail;
     }

     printf ("Passed Conformance Test 14.8.0.1\n");
     return;

Fail:
     printf ("Failed Conformance Test 14.8.0.1\n");
    }
