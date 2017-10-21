/* Conformance Test 14.9.0.1:  Verification of tolower, _tolower, toupper, */
/*                             _toupper functions                          */

#include <ctype.h>

main ()
  {
   int   i, j;
   char  ch;
   unsigned char uc;


   /* tolower:  converts uppercase letter to lowercase letter; if character */
   /*           is not alphabetic, then just returns character unchanged    */

   for (ch = 'A', uc = 'a'; uc <= 'z'; ch++, uc++)
     {
       j = tolower (ch);
       if (j != uc)
           goto Fail;
       j = _tolower (ch);
       if (j != uc)
           goto Fail;

       j = tolower (uc);
       if (j != uc)
           goto Fail;
       j = _tolower (uc);
       if (j != uc)
           goto Fail;
     }


   /* toupper:  converts lowercase letter to uppercase letter; if character */
   /*           is not alphabetic, then just returns character unchanged    */

   for (ch = 'A', uc = 'a'; uc <= 'z'; ch++, uc++)
     {
       j = toupper (uc);
       if (j != ch)
           goto Fail;
       j = _toupper (uc);
       if (j != ch)
           goto Fail;

       j = toupper (ch);
       if (j != ch)
           goto Fail;
       j = _toupper (ch);
       if (j != ch)
           goto Fail;
     }


     printf ("Passed Conformance Test 14.9.0.1\n");
     return;

Fail:
     printf ("Failed Conformance Test 14.9.0.1\n");
    }
