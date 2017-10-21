/* Conformance Test 4.5.4.1:  Verification of function declarators */

#include <stddef.h>
#include <stdio.h>

/***************************************************************************/

static int I1 (int (*func1) (char a), int (*func2) (float f))
  {
   return ( ((*func1) ('a')) + (func2 (3.5)) );
  }

/***************************************************************************/

static int I2 (int (*func []) (char a))
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

   int Char1 (char ch);             /* define two different functions which */
   int Char2 (char ch);             /*   take 1 char parm and return int    */

   int Float1 (float f);            /* define two different functions which */
   int Float2 (float f);            /*   take 1 float parm and return int   */

   int (*f1Ptr) (char);                /* pointer to function returning int */
                                       /*   function has single char arg    */
   int (*f1Array [3]) (char);          /* array of pointers to functions    */
                                       /*   returning int & having single   */
                                       /*   char parameter                  */
   int (*f2Ptr) (float);               /* pointer to function returning int */
                                       /*   function has single float arg   */

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


   printf ("Passed Conformance Test 4.5.4.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.5.4.1\n");
  }


/***************************************************************************/

int Char1 (char ch)
  {
   return (ch + 'a');
  }

/***************************************************************************/

int Char2 (char ch)
  {
   return ((ch) + ('b'));
  }

/***************************************************************************/

int Float1 (float f)
  {
   return (int) ((f) * 5.0);
  }

/***************************************************************************/

int Float2 (float f)
  {
   return (int) (f / 2.0);
  }
