/***************************************************************
*
*  This is probably the most famous benchmark in use today.
*  It tests the speed that a compiler can do logic and looping
*  operations.  While there are things that you can do to make
*  this benchmark run faster under ORCA/C, we have not
*  doctored it in any way - this is the original benchmark
*  in its original form.
*
*  To get the best performance from the desktop development
*  environment, be sure and turn debugging off from the
*  Compile Dialog.  Use the Compile command from the Run menu
*  to get the compile dialog.
*
***************************************************************/

#pragma keep "Prime"
#pragma optimize -1
#pragma lint -1

#include <stdio.h>

#define true 1
#define false 0
#define size 8190

char flags[size+1];

void main (void)

{
int i,prime,k,count,iter;

printf("10 iterations\n");
for (iter = 1; iter <= 10; iter++) {
   count = 0;
   for (i = 0; i <= size; i++)
      flags[i] = true;
   for (i = 0; i <= size; i++) {
      if (flags[i]) {
         prime = i+i+3;
      /* printf("\n%d", prime); */
         for (k = i+prime; k <= size; k += prime)
            flags[k] = false;
         count++;
         }
      }
   }
   printf("\n%d primes.", count);
}
