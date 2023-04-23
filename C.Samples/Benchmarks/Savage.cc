/***************************************************************
*
*  Savage
*
*  Test the speed (and stability) of floating point functions.
*
*  To get the best performance from the desktop development
*  environment, be sure and turn debugging off from the
*  Compile Dialog.  Use the Compile command from the Run menu
*  to get the compile dialog.
*
****************************************************************/

#pragma keep "Savage"
#pragma optimize -1
#pragma lint -1

#define loop 250

#include <stdio.h>
#include <math.h>

int main (void)

{
int i;
double sum;

printf("Start...\n");
sum = 1.0;
for (i = 1; i < loop; ++i)
   sum = tan(atan(exp(log(sqrt(sum*sum)))))+1.0;
printf("sum = %e", sum);
return 0;
}
