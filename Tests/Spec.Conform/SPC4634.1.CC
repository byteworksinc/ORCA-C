/* File spc4634.1.cc; the second source file which accesses the external    */
/* variables defined in the main source file.  Part of Special Conformance  */
/* Test 4.6.3.4                                                             */

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


   count++;
   if (*(i2Ptr) != 9)
       goto Fail;

   count++;
   if (*(ch2Ptr) != 'z')
       goto Fail;

   count++;
   if (*(L2Ptr) != 27)
       goto Fail;

   count++;
   if (*(c2Ptr) != 100000)
       goto Fail;

   count++;
   if (fabs (*(f2Ptr) - 12.3456) > 0.0001)
       goto Fail;

   count++;
   if (fabs (*(d2Ptr) - 0.65) > 0.0001)
       goto Fail;

   count++;
   if (fabs (*(e2Ptr) - 4.7) > 0.0001)
       goto Fail;

   count++;
   if (*(ui2Ptr) != 20)
       goto Fail;

   count++;
   if (*(uL2Ptr) != 88)
       goto Fail;

   count++;
   if ((struct2Ptr->a != 999) || (fabs (struct2Ptr->b - 9.99) > 0.0001))
       goto Fail;

   count++;
   if (union2Ptr->i != 0)
       goto Fail;

   return 0;

Fail:
   printf ("Failed ExternTest: count = %d\n", count);
   return 1;
  }
