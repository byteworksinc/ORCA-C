/* Conformance Test 11.4.2.1:  Type qualifiers should be allowed both in  */
/*                             type casts and in the type-specifiers for  */
/*                             field lists.                               */

#include <stdio.h>

struct foo {
   int i;
   int const j;
   volatile int k;
   } ;

int main (void)

{
int i,j;

j = 4;
i = (const int) j;
i = (int volatile) j;

printf ("Passed Conformance Test 11.4.2.1\n");
}
