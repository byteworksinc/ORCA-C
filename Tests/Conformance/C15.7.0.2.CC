/* Conformance Test 15.7.0.2:  Verification of strtok function */

#include <stddef.h>
#include <string.h>

main ()
  {
   char string [] = " this is the source string, so creative! oh, yes";
   char *strPtr;


   /* First call to strtok pass the string to be parsed; subsequent calls */
   /* just pass a NULL pointer.  Separating character is space to start.  */

   strPtr = strtok (string, " ");
   if (strPtr != (&( (string) [(1)] )) )
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strPtr != &string [6])
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strPtr != &string [9])
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strPtr != &string [13])
       goto Fail;

   strPtr = strtok (NULL, ",");        /* now change the separator set */
   if (strPtr != &string [20])
       goto Fail;

   strPtr = strtok (NULL, ",");
   if (strPtr != &string [27])
       goto Fail;

   strPtr = strtok (NULL, "! &*");     /* make last calls to strtok        */
   if (strPtr != &string [45])         /* address of '\0' at end of string */
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strPtr != NULL)
       goto Fail;


   /* Check tokenized string created by successive calls to strtok. */

   strcpy(string, " this is the source string, so creative! oh, yes");

   strPtr = strtok (string, " ");
   if (strcmp (strPtr, "this"))
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strcmp (strPtr, "is"))
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strcmp (strPtr, "the"))
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strcmp (strPtr, "source"))
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strcmp (strPtr, "string,"))
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strcmp (strPtr, "so"))
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strcmp (strPtr, "creative!"))
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strcmp (strPtr, "oh,"))
       goto Fail;

   strPtr = strtok (NULL, " ");
   if (strcmp (strPtr, "yes"))
       goto Fail;


   /* Check "special" cases:  string is the null string, and the string */
   /*                         contains only separator characters        */

   strPtr = strtok ("", " ");
   if (strPtr != NULL)
       goto Fail;

   strPtr = strtok ("abc", "abc");
   if (strPtr != NULL)
       goto Fail;


   printf ("Passed Conformance Test 15.7.0.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 15.7.0.2\n");
  }
