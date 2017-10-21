/* Conformance Test 24.0.2:  Test // comments and the ability to ignore     */
/*                           them                                           */

#pragma keep "t"
#pragma lint -1

#include <stdio.h>

typedef enum {false, true} boolean;

boolean pass;

/* by default, // comments are allowed */

void Test1 (void)

{
int a;

a = 8 //* this is a test */ 2
;
if (a == 4)
   pass = false;
}

#pragma ignore 0

/* now // comments are not allowed */

void Test2 (void)

{
int a;

a = 8 //* this is a test */ 2
;
if (a == 8)
   pass = false;
}

int main (void)

{
pass = true;
Test1();
Test2();
if (pass)
   printf("Passed Conformance Test 24.0.2\n");
else
   printf("Failed Conformance Test 24.0.2\n");
}
