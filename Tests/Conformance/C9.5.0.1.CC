/* Conformance Test 9.5.0.1:  Verification of parameter passing conventions */

#include <stdio.h>
#include <math.h>

struct S { int   i;
           float f;
           comp  c [5]; };

union U { int  i;
        long L; };


/****************************************************************************/

void Func1 (int i, char ch [], float f, struct S s, union U u)
  {
   int j;

   for (j = 0; j < i; j++)                     /* alter array's contents */
       ch [j] = (char) (j + 0x41);

   s.i = 22;                  /* this should not change struct's contents */
   s.f = 8.0;
   s.c [0] = s.c [1] = s.c [2] = s.c [3] = s.c [4] = 32767;

   u.L = 2147483647l;          /* this should not change unions's contents */

   f = 9.9;                    /* this should not change float's contents  */
  }


/****************************************************************************/

main ()
  {
   char   string [4] = "hey";
   struct S s = { 1, 2.0, 1, 2, 3, 4, 5 };
   union  U u = { 9 };
   float  f = 0.5;

   Func1 (3, string, f, s, u);         /* call function to change only array */
   if (strcmp (string, "ABC"))
       goto Fail;

   if ((s.i != 1) || (fabs(s.f - 2.0) > 0.00001) || (s.c [0] != 1) ||
       (s.c [1] != 2) || (s.c [2] != 3) || (s.c [3] != 4) || (s.c [4] != 5))
       goto Fail;

   if ((u.i != 9) || (fabs(f - 0.5) > 0.00001))
       goto Fail;


   printf ("Passed Conformance Test 9.5.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 9.5.0.1\n");
 }
