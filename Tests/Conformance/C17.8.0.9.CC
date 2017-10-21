/* Conformance Test 17.8.0.9:  Verification of scanf, d format code */

#include <stdio.h>

main ()
  {
   char  string [] = "  +327678   -   -002147483647A   327677-22  123*";
   short i1;
   int   i;
   int   i2, i3;
   long  L1;
   char  ch;


   i1 = 0;                                     /* test format string of no */
   i  = sscanf (string, "%*05hd8");            /*   assignment, max. field */
   if (i != 0)                                 /*   width of 5, h ignored, */
       goto Fail;                              /*   character 8 must appear*/
   if (i1 != 0)                                /*   after 5 digits read    */
       goto Fail;

   i2 = 15;                                    /* test "plain vanilla" fmt */
   i  = sscanf (&string [9], "%d", &i2);       /*   string; data contains  */
   if (i != 1)                                 /*   a single minus sign    */
       goto Fail;
   if (i2 != 0)
       goto Fail;

   L1 = 0;                                     /* test format string of    */
   i  = sscanf (&string [15], "%12ldA", &L1);  /*   max. field width of 12,*/
   if (i != 1)                                 /*   long variable expected,*/
       goto Fail;                              /*   character A must appear*/
   if (L1 != -2147483647)                      /*   after digits read      */
       goto Fail;

   L1 = 0;                                     /* test fmt string of max   */
   i  = sscanf (&string [31], "%6ld%d", &L1, &i2);  /*   field width of 6, */
   if (i != 2)                                 /*   long variable expected,*/
       goto Fail;                              /*   followed by simple fmt */
   if ((L1 != 327677) || (i2 != -22))          /*   for integer            */
       goto Fail;

   i3 = 4;                                     /* test format string of    */
   i  = sscanf (&string [43], "%4hd*", &i3);   /*   max. field width of 4, */
   if (i != 1)                                 /*   short variable expectd,*/
       goto Fail;                              /*   character * must appear*/
   if (i3 != 123)                              /*   after digits read.  In */
       goto Fail;                              /*   the input, the number  */
                                               /*   of digits is only 3.   */
   i = sscanf (&string [47], "%c", &ch);       /* Ensure offending * has   */
   if (i != 1)                                 /*   been left in input.    */
       goto Fail;
   if (ch != '*')
       goto Fail;

   i = sscanf (&string [48], "%c", &ch);       /* Ensure sscanf returns EOF*/
   if (i != EOF)                               /*   when EOF encountered.  */
       goto Fail;

   printf ("Passed Conformance Test 17.8.0.9\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.9\n");
   return;
  }
