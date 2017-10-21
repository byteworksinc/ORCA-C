/* File spc4632.1.cc; the second source file which accesses the external */
/* arrays defined in the main source file.  Part of Special Conformance  */
/* Test 4.6.3.2                                                          */

#include <math.h>

int ExternTest (void)
  {
   int count = 0;

   struct S { int   a;
              float b; };
   union  U { int  i;
              long L; };

   /* Declare extern pointers */

   extern int      (*i2Ptr);
   extern char     (*ch2Ptr);
   extern long     (*L2Ptr);
   extern comp     (*c2Ptr);
   extern float    (*f2Ptr);
   extern double   (*d2Ptr);
   extern extended (*e2Ptr);

   extern unsigned int  (*ui2Ptr);
   extern unsigned long (*uL2Ptr);

   extern struct S (*struct2Ptr);
   extern union  U (*union2Ptr );

   /* also test pointer subscripting */

   count++;
   if ((*(i2Ptr) != 8) || (i2Ptr [1] != 9))
       goto Fail;

   count++;
   if ((*(ch2Ptr) != 'x') || (ch2Ptr [1] != 'y'))
       goto Fail;

   count++;
   if ((*(L2Ptr) != 17) || (L2Ptr [1] != 23))
       goto Fail;

   count++;
   if ((*(c2Ptr) != 45000) || (c2Ptr [1] != 500000))
       goto Fail;

   count++;
   if ((fabs (*(f2Ptr) - 123.456) > 0.0001) ||
       (fabs (f2Ptr [1] - 6.0e7) > 0.0001))
       goto Fail;

   count++;
   if ((fabs (*(d2Ptr) - 0.5e10) > 0.0001) ||
       (fabs (d2Ptr [1] - 3.27) > 0.0001))
       goto Fail;

   count++;
   if ((fabs (*(e2Ptr) - 7.4) > 0.0001) ||
       (fabs (e2Ptr [1] - 9.9) > 0.0001))
       goto Fail;

   count++;
   if ((*(ui2Ptr) != 10) || (ui2Ptr [1] != 11))
       goto Fail;

   count++;
   if ((*(uL2Ptr) != 4) || (uL2Ptr [1] != 4))
       goto Fail;

   count++;
   if ((struct2Ptr->a != 888) || ((struct2Ptr + 1)->a != 999))
       goto Fail;

   count++;
   if ((fabs (struct2Ptr->b - 8.88) > 0.0001) ||
       (fabs ((struct2Ptr + 1)->b - 9.99) > 0.0001))
       goto Fail;

   count++;
   if ((union2Ptr->i != 7777) || ((union2Ptr + 1)->i != 0))
       goto Fail;

   return 0;

Fail:
   printf ("failure in ExternTest: count = %d\n", count);
   return 1;
  }
