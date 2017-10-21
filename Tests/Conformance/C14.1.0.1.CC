/* Conformance Test 14.1.0.1:  Verification of isalnum, isalpha, isascii, */
/*                             and iscntrl                                */

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


   /* isalnum:  returns 0 if char is not in ['0'..'9', 'a'..'z', 'A'..'Z'] */

   for (ch = '0'; ch <= '9'; ch++)
     {
       j = isalnum (ch);
       if (j == 0)
           goto Fail;
     }

   for (uc = 'a'; uc <= 'z'; uc++)
     {
       j = isalnum (uc);
       if (j == 0)
           goto Fail;
     }

   for (uc = 'A'; uc <= 'Z'; uc++)
     {
       j = isalnum (uc);
       if (j == 0)
           goto Fail;
     }

   j = isalnum ('~');
   if (j != 0)
       goto Fail;


   /* isalpha:  returns 0 if char is not in ['a'..'z', 'A'..'Z'] */

   for (ch = '0'; ch <= '9'; ch++)
     {
       j = isalpha (ch);
       if (j != 0)
           goto Fail;
     }

   for (uc = 'a'; uc <= 'z'; uc++)
     {
       j = isalpha (uc);
       if (j == 0)
           goto Fail;
     }

   for (uc = 'A'; uc <= 'Z'; uc++)
     {
       j = isalpha (uc);
       if (j == 0)
           goto Fail;
     }

   j = isalpha ('~');
   if (j != 0)
       goto Fail;


   /* isascii:  returns 0 if int is not in the range 0..128 */

   for (k = 0, i = 0; i < 20; k++, i++)
     {
       j = isascii (k);
       if (j == 0)
           goto Fail;
     }

   for (uc = 20, i = 20; i < 39; uc++, i++)
     {
       j = isascii (uc);
       if (j == 0)
           goto Fail;
     }

   for (ch = 39, i = 39; i < 57; ch++, i++)
     {
       j = isascii (ch);
       if (j == 0)
           goto Fail;
     }

   for (L = 57, i = 57; i < 75; L++, i++)
     {
       j = isascii (L);
       if (j == 0)
           goto Fail;
     }

   for (ui1 = 75, i = 75; i < 93; ui1++, i++)
     {
       j = isascii (ui1);
       if (j == 0)
           goto Fail;
     }

   for (ul1 = 93, i = 93; i < 128; ul1++, i++)
     {
       j = isascii (ul1);
       if (j == 0)
           goto Fail;
     }

   for (i = 128; i < 256; i++)
     {
       j = isascii (i);
       if (j != 0)
           goto Fail;
     }


   /* iscntrl:  returns 0 if char is not in [0..31, 127] */

   for (i = 0; i <= 31; i++)
     {
       j = iscntrl ( (char) (i) );
       if (j == 0)
           goto Fail;
     }

   if ( (j = iscntrl (127)) == 0 )
       goto Fail;

   for (i = 32; i < 127; i++)
     {
       if ( (j = iscntrl ( (char) (i) )) != 0 )
           goto Fail;
     }

     printf ("Passed Conformance Test 14.1.0.1\n");
     return;

Fail:
     printf ("Failed Conformance Test 14.1.0.1\n");
    }
