/***************************************************************
*
*  QuickSort
*
*  Creates an array of long integers, then sorts the array.
*
*  To get the best performance from the desktop development
*  environment, be sure and turn debugging off from the
*  Compile Dialog.  Use the Compile command from the Run menu
*  to get the compile dialog.
*
***************************************************************/

#pragma keep "Quick"
#pragma optimize -1
#pragma lint -1

#include <stdio.h>
#include <stdlib.h>

#define maxNum 999                      /* size of array to sort - 1 */
#define count 10                        /* # of iterations */
#define modulus 0x00020000              /* for random number generator */
#define c 13849
#define a 25173

typedef long arrayType[maxNum];

arrayType buffer;                       /* array to sort */
long seed;                              /* seed for random number generator */


void Quick (int lo, int hi, arrayType base)

{
int i,j;
long pivot,temp;

if (hi > lo) {
  pivot = base[hi];
  i = lo-1;
  j = hi;
  do {
    do ++i; while ((base[i] < pivot) && (j > i));
    if (j > i)
       do --j; while ((base[j] > pivot) && (j > i));
    temp = base[i];
    base[i] = base[j];
    base[j] = temp;
    }
  while (j > i);
  base[j] = base[i];
  base[i] = base[hi];
  base[hi] = temp;
  Quick(lo, i-1, base);
  Quick(i+1, hi, base);
  }
}


long Random (long size)

{
seed = seed*a+c;
return seed % size;
}


int main (void)

{
int i,j;                                /* loop variables */
int pass;                               /* for checking the array */

seed = 7;
printf("Filling array and sorting %d times.\n", count);
for (i = 0; i < count; ++i) {
  for (j = 0; j < maxNum; ++j)
    buffer[j] = labs(Random(modulus));
  Quick(0, maxNum-1, buffer);
  }
printf("Done.\n");

pass = 1;
for (i = 0; i < maxNum-1; ++i)
  if (buffer[i] > buffer[i+1])
    pass = 0;
if (pass) {
  printf("The last array is sorted properly.\n");
  return 0;
  }
else {
  printf("The last array is NOT sorted properly!\n");
  return -1;
  }
}
