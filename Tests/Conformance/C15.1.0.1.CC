/* Conformance Test 15.1.0.1:  Verification of strcat, strncat functions */

#include <string.h>

main ()
  {
   char s1 [80] = "this is the first string argument";
   char s2 [80] = ", and this is the second string argument!";
   char s3 [160] = "";


   strcpy(s3, strcat (s1, s2));
   if (strlen (s3) != 74)
       goto Fail;
   if (strcmp (s3, "this is the first string argument, and this is the \
second string argument!"))
       goto Fail;

   strcpy(s1, "this is the first string argument");
   strcpy(s3, strncat (s1, s2, 17));
   if (strlen (s3) != 50)
       goto Fail;
   if (strcmp (s3, "this is the first string argument, and this is the"))
       goto Fail;

   strcpy(s1, "this is the first string argument");
   strcpy(s3, strncat (s1, s2, 50));
   if (strlen (s3) != 74)
       goto Fail;
   if (strcmp (s3, "this is the first string argument, and this is the \
second string argument!"))
       goto Fail;

   strcpy(s1, "this is the first string argument");
   strcpy(s1, strncat (s1, s2, -5));
   if (strcmp (s1, "this is the first string argument"))
       goto Fail;


   printf ("Passed Conformance Test 15.1.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 15.1.0.1\n");
  }
