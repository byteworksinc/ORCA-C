/* Conformance Test 14.3.0.1:  Verification of isdigit, isodigit, isxdigit */

#include <ctype.h>

main ()
  {
   int   i, j;
   char  ch;
   unsigned char uc;


   /* isdigit:  returns 0 if char is not in ['0'..'9']                     */
   /* isodigit: returns 0 if char is not in ['0'..'7']                     */
   /* isxdigit: returns 0 if char is not in ['0'..'9', 'a'..'f', 'A'..'F'] */

   for (ch = '0'; ch < '8'; ch++)
     {
       j = isdigit (ch);
       if (j == 0)
           goto Fail;
       j = isodigit (ch);
       if (j == 0)
           goto Fail;
       j = isxdigit (ch);
       if (j == 0)
           goto Fail;
     }

   for (ch = '8'; ch <= '9'; ch++)
     {
       j = isdigit (ch);
       if (j == 0)
           goto Fail;
       j = isodigit (ch);
       if (j != 0)
           goto Fail;
       j = isxdigit (ch);
       if (j == 0)
           goto Fail;
     }

   for (uc = 'a'; uc <= 'f'; uc++)
     {
       j = isdigit (uc);
       if (j != 0)
           goto Fail;
       j = isodigit (uc);
       if (j != 0)
           goto Fail;
       j = isxdigit (uc);
       if (j == 0)
           goto Fail;
     }

   for (uc = 'A'; uc <= 'F'; uc++)
     {
       j = isdigit (uc);
       if (j != 0)
           goto Fail;
       j = isodigit (uc);
       if (j != 0)
           goto Fail;
       j = isxdigit (uc);
       if (j == 0)
           goto Fail;
     }

   for (uc = 'G'; uc <= 'Z'; uc++)
     {
       j = isdigit (uc);
       if (j != 0)
           goto Fail;
       j = isodigit (uc);
       if (j != 0)
           goto Fail;
       j = isxdigit (uc);
       if (j != 0)
           goto Fail;
     }


     printf ("Passed Conformance Test 14.3.0.1\n");
     return;

Fail:
     printf ("Failed Conformance Test 14.3.0.1\n");
    }
