/* Conformance Test 15.6.0.1:  Verification of strspn, strcspn, strpbrk, and */
/*                             strrpbrk functions                            */

#include <stddef.h>
#include <string.h>

main ()
  {
   char s1 [80] = "a b c d e f g h i j k : ' - _ + ";
   char *strPtr;
   size_t i;


   /* strspn:  find length of first run of chars from set */

   i = strspn (s1, " abcde cbad ");    /* search s1 for only chars in set */
   if (i != 10)
       goto Fail;

   i = strspn (s1, " +_-':kjihgfedcba");   /* all chars in set are in s1  */
   if (i != 32)                            /*   should return length (s1) */
       goto Fail;

   i = strspn (s1, "");                    /* should return 0 */
   if (i != 0)
       goto Fail;


   /* strcspn:  find length of first run of chars not in set */

   i = strcspn (s1, "fg:");                /* search s1 for chars not in set */
   if (i != 10)
       goto Fail;

   i = strcspn (s1, " +_-':kjihgfedcba");  /* all chars in set are in s1  */
   if (i != 0)                             /*   should return 0           */
       goto Fail;

   i = strcspn (s1, "");                   /* should return strlen */
   if (i != strlen(s1))
       goto Fail;


   /* strpbrk:  return pointer to 1st char in set */

   strPtr = strpbrk (s1, "fg:");           /* search s1 for chars not in set */
   if (strPtr != &(s1 [10]))
       goto Fail;

   strPtr = strpbrk (s1, " +_-':kjihgfedcba"); /* all chars in set are in s1  */
   if (strPtr != s1)                           /*   should return ptr to start*/
       goto Fail;

   strPtr = strpbrk (s1, "");                   /* should return NULL */
   if (strPtr != NULL)
       goto Fail;


   /* strrpbrk:  return pointer to last char in set */

   strPtr = strrpbrk (s1, "fg:");           /* search s1 for last char in set */
   if (strPtr != &(s1 [22]))
       goto Fail;

   strPtr = strrpbrk (s1, " +_-':kjihgfedcba"); /* all chars in set are in s1 */
   if (strPtr != &(s1[31]))
       goto Fail;

   strPtr = strrpbrk (s1, "");          /* should return ptr to end of string */
   if (strPtr != NULL)
       goto Fail;


   printf ("Passed Conformance Test 15.6.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 15.6.0.1\n");
  }
