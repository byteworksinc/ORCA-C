/* Deviance Test 3.3.3.1:  Ensure macros which expand into preprocessor */
/*                         commands are not parsed as preprocessor cmds */

#define includeFile    #include <string.h>
#define badValue       #define  reallyBadValue     5

main ()
  {
   includeFile
   badValue
   printf ("Failed Deviance Test 3.3.3.1\n");
  }


