/* Conformance Test 15.5.0.1:  Verification of strchr, strpos, strrchr, and */
/*                             strrpos functions                            */

#include <stddef.h>
#include <string.h>

main ()
  {
   char s1 [80] = "this is the first string argument";
   char *strPtr;
   size_t i;

   strPtr = strchr (s1, 's');          /* search s1 for 1st occurrence of 's' */
   if (strPtr == NULL)
       goto Fail;
   if (strPtr != &(s1 [3]))
       goto Fail;

   strPtr = strchr (s1, 'z');          /* search s1 for char not in s1 */
   if (strPtr != NULL)
       goto Fail;

   i = strpos (s1, 'f');               /* find position of 1st 'f' in s1 */
   if (i != 12)
       goto Fail;

   i = strpos (s1, 'x');               /* find position of char not in s1 */
   if (i != -1)
       goto Fail;

   i = strpos (s1, '\0');              /* find position of terminating null */
   if (i != 33)
       goto Fail;

   strPtr = strrchr (s1, 's');        /* search s1 for last occurrence of 's' */
   if (strPtr == NULL)
       goto Fail;
   if (strPtr != &(s1 [18]))
       goto Fail;

   strPtr = strrchr (s1, 'z');          /* search s1 for char not in s1 */
   if (strPtr != NULL)
       goto Fail;

   i = strrpos (s1, 'g');               /* find position of last 'g' in s1 */
   if (i != 27)
       goto Fail;

   i = strrpos (s1, 'x');               /* find position of char not in s1 */
   if (i != -1)
       goto Fail;

   i = strrpos (s1, '\0');              /* find position of terminating null */
   if (i != 33)
       goto Fail;

   printf ("Passed Conformance Test 15.5.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 15.5.0.1\n");
  }
