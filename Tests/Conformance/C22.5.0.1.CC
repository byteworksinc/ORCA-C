/* Conformance Test 22.5.0.1:  Verification of bsearch, qsort functions */

#include <stddef.h>
#include <stdlib.h>


/******************************************************************************/

int Compare (int *i1, int *i2)
  {
   if (*i1 < *i2)
       return (-1);

   else if (*i1 > *i2)
       return (1);

   else
       return 0;
  }


/******************************************************************************/

main ()
  {
   int i [10] = { 3, 4, 6, 8, 0, 2, 1, 5, 3, 7 };
   int j, *iptr;


   /* First sort the array with the qsort routine, then check results. */

   qsort ( (int *) (i), 10, sizeof (int), Compare );

   for (j = 0; j < 4; j++)
       if (i [j] != j)
           goto Fail;

   for (j = 3; j < 9; j++)
       if (i [j+1] != j)
           goto Fail;


   /* Now call bsearch to find some values in the array. */

   j    = 7;
   iptr = (int *) bsearch ( &j, i, 10, sizeof (int), Compare );
   if (iptr != &i [8])
       goto Fail;

   j    = 0;
   iptr = (int *) bsearch ( &j, i, 10, sizeof (int), Compare );
   if (iptr != i)
       goto Fail;

   j    = -3;
   iptr = (int *) bsearch ( &j, i, 10, sizeof (int), Compare );
   if (iptr != NULL)
       goto Fail;

   printf ("Passed Conformance Test 22.5.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 22.5.0.1\n");
  }
