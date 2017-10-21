/* File spc4636.1.cc; the second source file which accesses the external */
/* arrays defined in the main source file.  Part of Special Conformance  */
/* Test 4.6.3.6                                                          */


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
   if (*(ch2Ptr) != 'y')
       goto Fail;

   count++;
   if (*(L2Ptr) != 23)
       goto Fail;

/* count++;
   if (*(c2Ptr) != 500000)
       goto Fail; */

   count++;
   if (fabs (*(f2Ptr) - 6.0E7) > 0.0001)
       goto Fail;

   count++;
   if (fabs (*(d2Ptr) - 3.27) > 0.0001)
       goto Fail;

   count++;
   if (fabs (*(e2Ptr) - 9.9) > 0.0001)
       goto Fail;

   count++;
   if (*(ui2Ptr) != 11)
       goto Fail;

   count++;
   if (*(uL2Ptr) != 4)
       goto Fail;

   count++;
   if ((struct2Ptr->a != 999) || (fabs (struct2Ptr->b - 9.99) > 0.0001))
       goto Fail;

   count++;
   if (union2Ptr->i != 0)
       goto Fail;

   return 0;

Fail:
   printf ("Failure in ExternTest: count = %d\n", count);
   return 1;
  }
