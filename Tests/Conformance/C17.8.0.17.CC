/* Conformance Test 17.8.0.17:  Verification of scanf, d format code */

#include <stdio.h>

int main (void)
  {
   short i1, i3;
   int   i;
   int   i2;
   long  L1;
   char  ch;
   FILE  *f1;


   /* Redirect standard input to a data file. */

   f1 = fopen ("3/tmp", "wb+");                /* open input file for test */
   if (f1 == NULL)
       goto Fail1;
   fprintf(f1, "    +327678   -0   -002147483647A   327677-22  123*\r");
   fclose(f1);

   stdin = freopen ("3/tmp", "r", stdin);
   if (stdin == NULL)
       goto Fail1;

   i1 = 0;                                     /* test format string of no */
   i  = scanf ("%*06hd8");                     /*   assignment, max. field */
   if (i != 0)                                 /*   width of 6, h ignored, */
       goto Fail;                              /*   character 8 must appear*/
   if (i1 != 0)                                /*   after 5 digits read    */
       goto Fail;

   i2 = 15;                                    /* test "plain vanilla" fmt */
   i  = scanf ("%d", &i2);                     /*   string; data contains  */
   if (i != 1)                                 /*   "-0"                   */
       goto Fail;
   if (i2 != 0)
       goto Fail;

   L1 = 0;                                     /* test format string of    */
   i  = scanf ("%13ldA", &L1);                 /*   max. field width of 13,*/
   if (i != 1)                                 /*   long variable expected,*/
       goto Fail;                              /*   character A must appear*/
   if (L1 != -2147483647)                      /*   after digits read      */
       goto Fail;

   L1 = 0;                                     /* test format string of    */
   i  = scanf ("%6ld%d", &L1, &i2);            /*   max. field width of 6, */
   if (i != 2)                                 /*   long variable expected,*/
       goto Fail;                              /*   followed by simple fmt */
   if ((L1 != 327677) || (i2 != -22))          /*   for integer            */
       goto Fail;

   i3 = 4;                                     /* test format string of    */
   i  = scanf ("%4hd", &i3);                   /*   max. field width of 4, */
   if (i != 1)                                 /*   short variable expectd,*/
       goto Fail;                              /*   character * must appear*/
   if (i3 != 123)                              /*   after digits read.  In */
       goto Fail;                              /*   the input, the number  */
                                               /*   of digits is only 3.   */
   i = scanf ("%c", &ch);                      /* Ensure offending * has   */
   if (i != 1)                                 /*   been left in input.    */
       goto Fail;
   if (ch != '*')
       goto Fail;

   i = scanf ("%c", &ch);                      /* Ensure scanf returns EOF */
   if (i != 1)                                 /*   when EOF encountered.  */
       goto Fail;
   if (ch != '\n')
       goto Fail;
   i = scanf ("%c", &ch);
   if (i != EOF)
       goto Fail;

   stdin = freopen (".CONSOLE", "r", stdin);   /* reset stdin and quit */
   if (stdin == NULL)
       goto Fail1;

   printf ("Passed Conformance Test 17.8.0.17\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 17.8.0.17\n");
   return 0;

Fail1:
   printf ("Unable to redirect stdin for Conformance Test 17.8.0.17\n");
   return 0;
  }
