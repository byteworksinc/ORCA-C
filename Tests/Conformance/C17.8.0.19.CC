/* Conformance Test 17.8.0.19:  Verification of scanf, o format code */

#include <stdio.h>

main ()
  {
   int   i;
   unsigned short us1;
   unsigned int   ui1;
   unsigned long  ul1;
   FILE  *f1;


   /* Redirect standard input from a file. */

   f1 = fopen ("3/tmp", "wb+");                /* open input file for test */
   if (f1 == NULL)
       goto Fail1;
   fprintf(f1, "     77777   D    37777777777m   117777526");
   fclose(f1);

   stdin = freopen ("3/tmp", "r", stdin);
   if (stdin == NULL)
       goto Fail1;

   us1 = 2;                                    /* test format string of no */
   i   = scanf ("%*05ho8");                    /*   assignment, max. field */
   if (i != 0)                                 /*   width of 5, h ignored, */
       goto Fail;                              /*   character 8 must appear*/
   if (us1 != 2)                               /*   after 5 digits read    */
       goto Fail;

   i = scanf ("%o", &ui1);                     /* test "plain vanilla" fmt */
   if (i != 0)                                 /*   string; data contains  */
       goto Fail;                              /*   the character 'D'      */

   ul1 = 0;                                    /* test format string of    */
   i   = scanf ("D %12lom", &ul1);             /*   max. field width of 12,*/
   if (i != 1)                                 /*   long variable expected,*/
       goto Fail;                              /*   character m must appear*/
   if (ul1 != 4294967295u)                     /*   after digits read      */
       goto Fail;

   ul1 = 0;                                    /* test format string of    */
   i  = scanf ("%7lo%o", &ul1, &ui1);          /*   max. field width of 6, */
   if (i != 2)                                 /*   long variable expected,*/
       goto Fail;                              /*   followed by simple fmt */
   if ((ul1 != 327677) || (ui1 != 22))         /*   for integer            */
       goto Fail;

   stdin = freopen (".CONSOLE", "r", stdin);   /* reset stdin and quit */
   if (stdin == NULL)
       goto Fail1;

   printf ("Passed Conformance Test 17.8.0.19\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.19\n");
   return;

Fail1:
   printf ("Unable to redirect stdin for Conformance Test 17.8.0.19\n");
   return;
  }
