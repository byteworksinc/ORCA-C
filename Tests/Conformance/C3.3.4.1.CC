/* Conformance Test 3.3.4.1:  Verification of ANSI C and ORCA/C predefined */
/*                            macros                                       */

#include <string.h>

int printf(const char *, ...);

int main (void)
  {
   int    i, j;
   float  x, y;
   char str[80], fname[20] = "C3.3.4.1.CC";

#line 10
   if (__LINE__ != 10)
       goto Fail;

   strcpy(str, __FILE__);
   i = strlen(str)-strlen(fname);
   if ((strcmp (&str[i], fname)) != 0)
       goto Fail;

   if (__STDC__ == 0)
       goto Fail;

   if (__ORCAC__ != 1)
       goto Fail;

   printf ("Passed Conformance Test 3.3.4.1\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 3.3.4.1\n");
  }
