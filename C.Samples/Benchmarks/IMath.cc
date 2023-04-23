/***************************************************************
*
*  Integer Math
*
*  Test the speed of the four basic integer math operations.
*
*  To get the best performance from the desktop development
*  environment, be sure and turn debugging off from the
*  Compile Dialog.  Use the Compile command from the Run menu
*  to get the compile dialog.
*
****************************************************************/

#pragma keep "IMath"
#pragma optimize -1
#pragma lint -1

#include <stdio.h>

#define ITER 10000


int main (void)

{
int a,b,c,d,e,f;
unsigned i;

printf("Start timing...\n");
b = 1000;
c = 10;
d = 100;
e = 5;
f = 10;
for (i = 0; i < ITER; ++i) {
   a = b+c-d*e/f;
   a = b+c-d*e/f;
   a = b+c-d*e/f;
   a = b+c-d*e/f;
   a = b+c-d*e/f;
   a = b+c-d*e/f;
   a = b+c-d*e/f;
   a = b+c-d*e/f;
   a = b+c-d*e/f;
   a = b+c-d*e/f;
   a = b+c-d*e/f;
   }
if (a == 960) {
   printf("Stop timing - correct result.\n");
   return 0;
   }
else {
   printf("INCORRECT RESULT.\n");
   return -1;
   }
}
