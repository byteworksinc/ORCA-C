/* Conformance Test 14.2.0.1:  Verification of iscsym, iscymf */

#include <ctype.h>

main ()
  {
   int   i, j;
   char  ch;
   unsigned char uc;


   /* iscsym: returns 0 if char is not in ['0'..'9', 'a'..'z', 'A'..'Z', '_'] */
   /* iscsymf: returns 0 if char is not in ['a'..'z', 'A'..'Z', '_']          */

   for (ch = '0'; ch <= '9'; ch++)
     {
       j = iscsym (ch);
       if (j == 0)
           goto Fail;
       j = iscsymf (ch);
       if (j != 0)
           goto Fail;
     }

   for (uc = 'a'; uc <= 'z'; uc++)
     {
       j = iscsym (uc);
       if (j == 0)
           goto Fail;
       j = iscsymf (uc);
       if (j == 0)
           goto Fail;
     }

   for (uc = 'A'; uc <= 'Z'; uc++)
     {
       j = iscsym (uc);
       if (j == 0)
           goto Fail;
       j = iscsymf (uc);
       if (j == 0)
           goto Fail;
     }

   j = iscsym ('_');
   if (j == 0)
       goto Fail;
   j = iscsymf ('_');
   if (j == 0)
       goto Fail;

   j = iscsym ('~');
   if (j != 0)
       goto Fail;

     printf ("Passed Conformance Test 14.2.0.1\n");
     return;

Fail:
     printf ("Failed Conformance Test 14.2.0.1\n");
    }
