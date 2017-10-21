/* Conformance Test 14.7.0.1:  Verification of toascii function */

#include <ctype.h>

main ()
  {
   int   i, j;
   char  ch;
   short k;
   long  L;
   unsigned int  ui1;
   unsigned long ul1;
   unsigned char uc;


   /* toascii:  returns ASCII value of any integral value by returning only */
   /*           the 7 low order bits                                        */

   for (k = 0, i = 0; i < 20; k++, i++)
     {
       j = toascii (k);
       if (j != k)
           goto Fail;
     }

   for (uc = 20, i = 20; i < 39; uc++, i++)
     {
       j = toascii (uc);
       if (j != uc)
           goto Fail;
     }

   for (ch = 39, i = 39; i < 57; ch++, i++)
     {
       j = toascii (ch);
       if (j != ch)
           goto Fail;
     }

   for (L = 57, i = 57; i < 75; L++, i++)
     {
       j = toascii (L);
       if (j != L)
           goto Fail;
     }

   for (ui1 = 75, i = 75; i < 93; ui1++, i++)
     {
       j = toascii (ui1);
       if (j != ui1)
           goto Fail;
     }

   for (ul1 = 93, i = 93; i < 128; ul1++, i++)
     {
       j = toascii (ul1);
       if (j != ul1)
           goto Fail;
     }

   for (k = 0, i = 128; i < 256; k++, i++)      /* check truncation */
     {
       j = toascii (i);
       if (j != k)
           goto Fail;
     }


     printf ("Passed Conformance Test 14.7.0.1\n");
     return;

Fail:
     printf ("Failed Conformance Test 14.7.0.1\n");
    }
