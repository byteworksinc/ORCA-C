/* Conformance Test 17.8.0.18:  Verification of scanf, u format code */

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
   fprintf(f1, "     327678   D    4294967295m   32767722\r");
   fclose(f1);

   stdin = freopen ("3/tmp", "r", stdin);
   if (stdin == NULL)
       goto Fail1;

   ui1 = 2;                                    /* test format string of no */
   i   = scanf ("%*05hu8");                    /*   assignment, max. field */
   if (i != 0)                                 /*   width of 5, h ignored, */
       goto Fail;                              /*   character 8 must appear*/
   if (ui1 != 2)                               /*   after 5 digits read    */
       goto Fail;

   i = scanf ("%u", &ui1);                     /* test "plain vanilla" fmt */
   if (i != 0)                                 /*   string; data contains  */
       goto Fail;                              /*   the character 'D'      */

   ul1 = 0;                                    /* test format string of    */
   i   = scanf ("D %12ldm", &ul1);             /*   max. field width of 12,*/
   if (i != 1)                                 /*   long variable expected,*/
       goto Fail;                              /*   character m must appear*/
   if (ul1 != 4294967295u)                     /*   after digits read      */
       goto Fail;

   ul1 = 0;                                    /* test format string of    */
   i  = scanf ("%6lu%u", &ul1, &ui1);          /*   max. field width of 6, */
   if (i != 2)                                 /*   long variable expected,*/
       goto Fail;                              /*   followed by simple fmt */
   if ((ul1 != 327677) || (ui1 != 22))         /*   for integer            */
       goto Fail;

   stdin = freopen (".CONSOLE", "r", stdin);   /* reset stdin and quit */
   if (stdin == NULL)
       goto Fail1;

   printf ("Passed Conformance Test 17.8.0.18\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.18\n");
   return;

Fail1:
   printf ("Unable to redirect stdin for Conformance Test 17.8.0.18\n");
   return;
  }
