/* Conformance Test 23.1.0.1:  Verification of c2pstr, p2cstr functions */

#include <string.h>

main ()
  {
   char *ptr;
   char pstring [] = "\pThis is a so-called Pascal string";
   char cstring [] = "This string is 289 characters long: a b c d e f g h i j "
"a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M "
"a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M "
"a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M";

   ptr = c2pstr (cstring);
   if ( ptr[0] != 255 )
       goto Fail;
   if (! (strcmp (ptr, "\pThis string is 289 characters long: a b c d e f g h i \
j a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L \
M a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L \
M a b c d e f g h i j k l m n o p q r s t u v")) )
       goto Fail;

   ptr = p2cstr (pstring);
   if ( (strlen (ptr)) != 33 )
       goto Fail;
   if (strcmp (ptr, "This is a so-called Pascal string"))
       goto Fail;

   printf ("Passed Conformance Test 23.1.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 23.1.0.1\n");
  }
