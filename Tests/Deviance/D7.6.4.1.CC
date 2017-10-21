/* Deviance Test 7.6.4.1:  Ensure illegal use of relational operators is */
/*                         detected                                      */

#include <stdio.h>

main ()
  {
   float f = 1.1, *fptr = &f;      /* can only compare pointers with pointers */
   char  ch = 'a', *chptr = &ch;

   int i;

   i = (fptr <= 0xabcd);
   i = (i < fptr);
   i = chptr >= ch;
   i = 'Z' > chptr;
   i = fptr < 5.5;

   printf ("Failed Deviance Test 7.6.4.1\n");
  }
