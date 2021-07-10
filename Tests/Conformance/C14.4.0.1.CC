/* Conformance Test 14.4.0.1:  Verification of isgraph, isprint, ispunct */

#include <ctype.h>

main ()
  {
   int   i, j;
   char  ch;
   unsigned char uc;


   /* isgraph:  returns 0 if char is not in [ASCII 33 .. 126] */
   /* isprint:  returns 0 if char is not in [ASCII 32 .. 126] */
   /* ispunct: returns 0 if char not in [ !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~] */

   j = isprint (' ');
   if (j == 0)
       goto Fail;

   for (ch = 33; ch < 127; ch++)
     {
       j = isgraph (ch);
       if (j == 0)
           goto Fail;
       j = isprint (ch);
       if (j == 0)
           goto Fail;
     }

   for (uc = '!'; uc < '0'; uc++)          /* ! through / */
     {
       j = ispunct (uc);
       if (j == 0)
           goto Fail;
     }

   for (uc = ':'; uc < 'A'; uc++)          /* : thru @ */
     {
       j = ispunct (uc);
       if (j == 0)
           goto Fail;
     }

   for (ch = '['; ch < 'a'; ch++)          /* [ thru ` */
     {
       j = ispunct (ch);
       if (j == 0)
           goto Fail;
     }

   for (uc = 0x7B; uc < 127; uc++)         /* { thru ~ */
     {
       j = ispunct (uc);
       if (j == 0)
           goto Fail;
     }

   for (i = 0; i < 32; i++)                /* 0 for non-set characters */
     {
       j = isgraph ((char) i);
       if (j != 0)
           goto Fail;
       j = isprint ((char) i);
       if (j != 0)
           goto Fail;
       j = ispunct ((char) i);
       if (j != 0)
           goto Fail;
     }
   if (ispunct(' '))
       goto Fail;

     printf ("Passed Conformance Test 14.4.0.1\n");
     return;

Fail:
     printf ("Failed Conformance Test 14.4.0.1\n");
    }
