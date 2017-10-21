/* Conformance Test 14.6.0.1:  Verification of isspace function */

#include <ctype.h>

main ()
  {
   int   i, j;
   char  ch;
   unsigned char uc;


   /* isspace:  returns 0 if char is not in [ \t \r \n \v \f] */

   j = isspace (' ');
   if (j == 0)
       goto Fail;

   for (uc = 9; uc <= '\r'; uc++)
     {
       j = isspace (uc);
       if (j == 0)
           goto Fail;
     }

   for (ch = 'A'; ch <= 'Z'; ch++)
     {
       j = isspace (ch);
       if (j != 0)
           goto Fail;
     }

     printf ("Passed Conformance Test 14.6.0.1\n");
     return;

Fail:
     printf ("Failed Conformance Test 14.6.0.1\n");
    }
