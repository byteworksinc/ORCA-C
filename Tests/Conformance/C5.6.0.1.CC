/* Conformance Test 5.6.0.1:   Make sure structs can be forward         */
/*                             declared.                                */

#include <stdio.h>

int fail = 0;

struct foo bar;
struct foo {int i,j;};

void f(void)

{
struct foo {char j,k;} bar;

bar.j = 'a';
bar.k = 'b';
if ((bar.j != 'a') || (bar.k != 'b'))
   fail = 1;
}

int main(void)

{
bar.i = -1;
bar.j = 3;
if ((bar.i != -1) || (bar.j != 3))
   fail = 1;
f();

if (fail)
   printf ("Failed Conformance Test 5.6.0.1\n");
else
   printf ("Passed Conformance Test 5.6.0.1\n");
}
