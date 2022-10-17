/* Special Conformance Test 23.2.0.1:  Verification of commandline   */
/*                                                                   */
/* Other files needed:  spc23.201.exec - EXEC file which compiles,   */
/*                                       links, and executes test    */
/*                                       file with parameters        */

#include <orca.h>
#include <string.h>

int printf(const char *, ...);

int main (void)
  {
   char *cmdLine;

   cmdLine = commandline ();
   if (strcmp (cmdLine, "3/spc23.2  one two three four"))
       goto Fail;

   printf ("Passed Special Conformance Test 23.2.0.1\n");
   return 0;

Fail:
   printf ("Failed Special Conformance Test 23.2.0.1\n");
  }
