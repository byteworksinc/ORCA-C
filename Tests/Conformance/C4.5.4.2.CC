/* Conformance Test 4.5.4.2:  Verification of function declarators, using  */
/*                            non-prototyped form                          */

#include <stdio.h>
#include <stddef.h>

/***************************************************************************/

static int I1 (func1, func2)
  int (*func1) ();
  int (*func2) ();
  {
   return ( ((*func1) ('a')) + ((*func2) (3.5)) );
  }

/***************************************************************************/

static int I2 (func)
  int (*func []) ();
  {
   int j;

   j  = (*func) ('@');
   j += (func[1]) ('@');
   return j;
  }

/***************************************************************************/


main ()
  {
   int i;

   int Char1 (), Char2 ();                    /* define external functions */
   int Float1 (), Float2();

   int (*f1Ptr) ();                    /* pointer to function returning int */
   int (*f2Ptr) ();
   int (*f1Array [3]) ();              /* array of pointers to functions    */
                                       /*   returning int                   */

   f1Ptr = Char1;
   f2Ptr = Float2;
   i = I1 (f1Ptr, f2Ptr);
   if (i != 0xC3)
       goto Fail;

   f1Ptr = Char2;
   f2Ptr = Float1;
   i = I1 (f1Ptr, f2Ptr);
   if (i != 0xD4)
       goto Fail;

   i = I1 (Char1, Float1);
   if (i != 0xD3)
       goto Fail;

   f1Array [0] = Char1;
   f1Array [1] = Char2;
   f1Array [2] = NULL;
   i = I2 (f1Array);
   if (i != 0x143)
       goto Fail;


   printf ("Passed Conformance Test 4.5.4.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.5.4.2\n");
  }


/***************************************************************************/

int Char1 (ch)
  char ch;
  {
   return (ch + 'a');
  }

/***************************************************************************/

int Char2 (ch)
  char ch;
  {
   return ((ch) + ('b'));
  }

/***************************************************************************/

int Float1 (f)
  float f;
  {
   return (int) ((f) * 5.0);
  }

/***************************************************************************/

int Float2 (f)
  float f;
  {
   return (int) (f / 2.0);
  }
