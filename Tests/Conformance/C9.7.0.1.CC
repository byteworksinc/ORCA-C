/* Conformance Test 9.7.0.1:  Verification of function return types:  enum,  */
/*                            pointer to array, pointer to function, struct, */
/*                            and union                                      */

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

struct S { float    f;
           extended e; };

union  U { double   d;
           extended e; };

enum E { a, b, c };


/**************************************************************************/

void V1 (void)
  {
  }


/**************************************************************************/

main ()
  {
   /* Func1 returns an enumeration E constant. */

   static enum E Func1 (char ch, int i, double d, struct S s);


   /* Func2 returns a pointer to an array of integers. */

   static int  ( *Func2 (long L, extended e, enum E e0) ) [];


   /* Func3 returns a pointer to a function returning void. */

   static void ( *Func3 (union U u, unsigned long ul1) ) ();


   /* Func4 returns a struct S. */

   static struct S Func4 (extended e, unsigned short s, float f);


   /* Func5 returns a union U. */

   static union U Func5 (struct S s, double d, char ch, comp c);


   extended e = 8.88e-2;
   double   d = 47.81;
   float    f = 32.32;
   comp     c = 222222;
   long     L = 33769;
   char    ch = 'k';
   int      i = 897;
   enum E  e0 = b;

   int      (*j)[], (*m)[], k;

   unsigned short sh  = 0177;
   unsigned long  ul1 = 0x11001100;

   struct S s = { 5.5, 6.6 };
   union  U u = 4.5;

   void (*funcPtr) (void);


   e0 = Func1 (ch, i, d, s);           /* call functions & test return values */
   if (e0 != a)
       goto Fail;

   m = j = Func2 (L, e, e0);
   if (j == NULL)
       goto Fail;
   for (k = 0; k < 5; k++)
       if ((*j)[k] != k)
           goto Fail;
   free (m);

   funcPtr = Func3 (u, ul1);
   if (funcPtr != V1)
       goto Fail;

   s = Func4 (e, sh, f);
   if ((fabs(s.f - 2340.0) > 0.01) || (fabs(s.e - (-159.4088)) > 0.001))
       goto Fail;

   u = Func5 (s, d, ch, c);
   if (fabs(u.e - 123.456e+300) > 1e295)
       goto Fail;


   printf ("Passed Conformance Test 9.7.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 9.7.0.1\n");
 }


/**************************************************************************/

static enum E Func1 (char ch, int i, double d, struct S s)
  {
   d = s.f - 0.5;
   if (d != 5.0)
       goto Fail;
   i += ch;
   if (i != 1004)
       goto Fail;
   return a;

Fail:
   printf ("Failure in Conformance Test 9.7.0.1, Func1\n");
   exit (-1);
  }


/**************************************************************************/

static int  ( *Func2 (long L, extended e, enum E e0) ) []
  {
   int (*i)[], *j, k;


   e += ((extended) (L) - (extended) (e0));    /* check passed parameters */
   if (fabs(e - 33769.0888) > 0.00001)
       goto Fail;

   i = (int (*)[]) calloc (5, sizeof (int));   /* create array to return */
   if (i == NULL)
       goto Fail;
   for (j = *i, k = 0; k < 5; k++, j++)
       *j = k;
   return (i);

Fail:
   printf ("Failure in Conformance Test 9.7.0.1, Func2\n");
   exit (-1);
  }


/**************************************************************************/

static void ( *Func3 (union U u, unsigned long ul1) ) ()
  {
   extended e;

   e = (extended) (u.d) + (extended) (ul1);
   if (e != 285217028.5)
       goto Fail;
   return V1;

Fail:
   printf ("Failure in Conformance Test 9.7.0.1, Func3\n");
   exit (-1);
  }


/**************************************************************************/

static struct S Func4 (extended e, unsigned short s, float f)
  {
   double d;
   struct S *SS;

   d = - ((double) (e)) - ((double) (s)) - ((double) (f));     /* test parms */
   if (fabs(d - (-159.4088)) > 0.00001)
       goto Fail;

   /* Create struct to return. */

   SS = (struct S *) calloc (1, sizeof (struct S));
   if (SS == NULL)
       goto Fail;
   SS->f = 23.4e+02;
   SS->e = d;
   return * SS;

Fail:
   printf ("Failure in Conformance Test 9.7.0.1, Func4\n");
   exit (-1);
  }


/**************************************************************************/

static union U Func5 (struct S s, double d, char ch, comp c)
  {
   extended e;
   comp     cp;
   union U  *u;

   e = s.f - d;                                 /* test parameters */
   if (fabs(e - 2292.19) > 0.01)
       goto Fail;

   cp = (comp) ch + c;
   if (cp != 222329)
       goto Fail;

   u = (union U *) calloc (1, sizeof (union U)); /* create union to return */
   if (u == NULL)
       goto Fail;
   u->e = 123.456E+300;
   return (*u);

Fail:
   printf ("Failure in Conformance Test 9.7.0.1, Func5\n");
   exit (-1);
  }
