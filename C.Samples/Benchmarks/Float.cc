/***************************************************************
*
*  Float
*
*  Test simple floating point operations.
*
*  To get the best performance from the desktop development
*  environment, be sure and turn debugging off from the
*  Compile Dialog.  Use the Compile command from the Run menu
*  to get the compile dialog.
*
***************************************************************/

#pragma keep "Float"
#pragma optimize -1
#pragma lint -1

#include <stdio.h>

#define const1 3.141597
#define const2 1.7839032e4
#define count 1000

int main(void)

{
double a,b,c;
int i;

a = const1;
b = const2;
printf("%d iterations.\n", count);
for (i = 0; i < count; ++i) {
  c = a*b;
  c = c/a;
  c = a*b;
  c = c/a;
  c = a*b;
  c = c/a;
  c = a*b;
  c = c/a;
  c = a*b;
  c = c/a;
  c = a*b;
  c = c/a;
  c = a*b;
  c = c/a;
  }
printf("Done.  C is %e.\n", c);
return 0;
}
