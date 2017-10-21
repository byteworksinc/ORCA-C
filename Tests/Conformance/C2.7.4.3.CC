/* Conformance Test 2.7.4.3:  Test strings of critical length in scanner */

#include <stdio.h>
#include <string.h>

main ()
  {
   int i;
   char *strPtr;
   char s1 [] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789";           /* 99 bytes   */

   char s2 [] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789A";          /* 100 bytes  */

   char s3 [] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789AB";         /* 101 bytes  */

   char s4 [] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789AB"          /* 100 bytes  */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnop";                        /* 17 bytes   */

   char s5 [] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789AB"          /* 100 bytes  */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopq";                       /* 18 bytes   */

   char s8 [] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789AB"          /* 100 bytes  */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqr"                       /* 18 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"            /* 98 bytes   */
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
0123456";


   /* Test first set of critical lengths:  99, 100, 101 */
   if (strcmp (s1, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789"))
       goto Fail;

   if (strcmp (s2, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789A"))
       goto Fail;

   if (strcmp (s3, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789AB"))
       goto Fail;

   /* Second set of critical lengths:  999, 1000, 1001 */
   if (strncmp (s4, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789AB", 100))
       goto Fail;
   strPtr = &s4 [100];
   for (i = 1; i < 10; i++)
     {
       if (strncmp (strPtr, s1, 98))
           goto Fail;
       strPtr += 98;
     }
   if (strcmp (strPtr, "abcdefghijklmnop"))
       goto Fail;

   if (strncmp (s5, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789AB", 100))
       goto Fail;
   strPtr = &s5 [100];
   for (i = 1; i < 10; i++)
     {
       if (strncmp (strPtr, s1, 98))
           goto Fail;
       strPtr += 98;
     }
   if (strcmp (strPtr, "abcdefghijklmnopq"))
       goto Fail;

   /* Third set of critical lengths:  3999, 4000, 4001 */
   if (strncmp (s8, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz01234567890123456789AB", 100))
       goto Fail;
   strPtr = &s8 [100];
   for (i = 1; i < 10; i++)
     {
       if (strncmp (strPtr, s1, 98))
           goto Fail;
       strPtr += 98;
     }
   if (strncmp (strPtr, "abcdefghijklmnopqr", 18))
       goto Fail;
   strPtr += 18;
   for (i = 0; i < 30; i++)
     {
       if (strncmp (strPtr, s1, 98))
           goto Fail;
       strPtr += 98;
     }
   if (strcmp (strPtr, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\
0123456"))
       goto Fail;

   printf ("Passed Conformance Test 2.7.4.3\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.4.3\n");
  }
