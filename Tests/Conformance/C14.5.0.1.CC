/* Conformance Test 14.5.0.1:  Verification of islower, isupper */

#include <ctype.h>

main ()
  {
   int   i, j;
   char  ch;
   unsigned char uc;


   /* islower:  returns 0 if char is not in ['a'..'z'] */
   /* isupper:  returns 0 if char is not in ['A'..'Z'] */

   for (uc = 'a'; uc <= 'z'; uc++)
     {
       j = islower (uc);
       if (j == 0)
           goto Fail;
       j = isupper (uc);
       if (j != 0)
           goto Fail;
     }

   for (ch = 'A'; ch <= 'Z'; ch++)
     {
       j = islower (ch);
       if (j != 0)
           goto Fail;
       j = isupper (ch);
       if (j == 0)
           goto Fail;
     }

     printf ("Passed Conformance Test 14.5.0.1\n");
     return;

Fail:
     printf ("Failed Conformance Test 14.5.0.1\n");
    }
