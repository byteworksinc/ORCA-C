/* Conformance Test 16.1.0.1: Verification of memchr, memcmp, memcpy, memmove */
/*                            library functions                               */

#include <stddef.h>
#include <string.h>
#include <stdlib.h>

main ()
  {
   int  i;
   char *rgn, *ptr1;
   char string [] = "Here is a string to copy to the first region!!! ";


   rgn = (char *) malloc (512);           /* allocate some memory for test */
   if (rgn == NULL)
       goto Fail1;


   /* Copy the string into the allocated area. */

   ptr1 = (char *) (memcpy (rgn, string, sizeof(string)+1));
   if (strcmp(ptr1,string))
       goto Fail;


   /* Ensure memmove works for overlapping regions. */

   memmove (rgn+40, rgn, sizeof(string)+1);
   if (strcmp(string, rgn+40))
       goto Fail;


   /* Test memchr by searching region for characters. */

   ptr1 = (char *) memchr (string, 'n', 50);
   if (ptr1 != string+14)
       goto Fail;

   ptr1 = (char *) (memchr (string, 'Z', 88));
   if (ptr1 != NULL)
       goto Fail;


   /* Verify that the region has the correct characters. */

   i = memcmp ( (char *) (rgn), (char *) (rgn + 40), 39);
   if (i)
       goto Fail;

   i = memcmp ( string, "Here is a string", 17);
   if (i <= 0)
       goto Fail;

   free (rgn);


   printf ("Passed Conformance Test 16.1.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 16.1.0.1\n");
   return;

Fail1:
   printf ("Unable to allocate memory for Conformance Test 16.1.0.1\n");
   return;
  }
