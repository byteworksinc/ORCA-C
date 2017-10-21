/* Conformance Test 11.4.2.1:  Type qualifiers should be allowed both in  */
/*                             type casts and in the type-specifiers for  */
/*                             field lists.                               */

#include <stdio.h>

struct foo {
   int i;
   const j;
   volatile k;
   } ;

main ()

{
int i,j;

j = 4;
i = (const) j;
i = (volatile) j;

printf ("Passed Conformance Test 11.4.2.1\n");
}
