/* Special Conformance Test 3.6.0.3:  Test explicit line numbering (#line) */
/*                                    with filenames                       */

#include <string.h>

int printf(const char *, ...);

#include <stdio.h>
#define  FileName(x)   x
#define  LINE_NUM      10
#line LINE_NUM FileName ("onemorefile")

int main (void)
  {
   if (strcmp (__FILE__, "onemorefile"))
     {
       printf ("Failed Special Conformance Test 3.6.0.3\n");
       printf ("Macro substitution in LINE fails\n");
       printf ("__FILE__ = %s\n", __FILE__);
     }

   else
       printf ("Passed Special Conformance Test 3.6.0.3\n");
  }
