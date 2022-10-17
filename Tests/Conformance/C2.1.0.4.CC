/* Conformance Test 2.1.0.4:  Verification of ANSI C trigraphs in */
/*                            character string constants          */

#include <string.h>

int printf(const char *, ...);

int main (void)
  {
   char a [] = "??=??/boh??'??!??-??(??<??)??>boy";

   if ((strcmp (a, "#\boh^|~[{]}boy")) != 0)
       goto Fail;

   printf ("Passed Conformance Test 2.1.0.4\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 2.1.0.4\n");
  }
