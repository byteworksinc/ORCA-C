/***************************************************************
*
*  Fibonacci
*
*  Recursively computes Fibonacci numbers to test the speed of
*  function calls.
*
*  To get the best performance from the desktop development
*  environment, be sure and turn debugging off from the
*  Compile Dialog.  Use the Compile command from the Run menu
*  to get the compile dialog.
*
****************************************************************/

#pragma keep "FIB"
#pragma optimize -1
#pragma lint -1

#include <stdio.h>

#define NTIMES 10                       /* # iterations */
#define NUMBER 23                       /* largest Fib # smaller than 32767 */


int Fibonacci(int x)

{
if (x > 2)
   return Fibonacci(x-1)+Fibonacci(x-2);
else
   return 1;
}


int main (void)

{
int value;
unsigned i;

printf("%d iterations:\n", NTIMES);
for (i = 0; i < NTIMES; ++i)
   value = Fibonacci(NUMBER);
printf("Fibonacci(%d) = %d\n", NUMBER, value);
return 0;
}
