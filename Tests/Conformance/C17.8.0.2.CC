/* Conformance Test 17.8.0.2:  Verification of fscanf, u format code */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int   i;
   unsigned short us1;
   unsigned int   ui1;
   unsigned long  ul1;


   f1 = fopen ("3/tmp", "wb+");                /* open input file for test */
   if (f1 == NULL)
       goto Fail1;
   fprintf(f1, "     327678   D    4294967295m   32767722\r");
   rewind(f1);

   ui1 = 2;                                    /* test format string of no */
   i   = fscanf (f1, "%*05hu8");               /*   assignment, max. field */
   if (i != 0)                                 /*   width of 5, h ignored, */
       goto Fail;                              /*   character 8 must appear*/
   if (ui1 != 2)                               /*   after 5 digits read    */
       goto Fail;

   i = fscanf (f1, "%u", &ui1);                /* test "plain vanilla" fmt */
   if (i != 0)                                 /*   string; data contains  */
       goto Fail;                              /*   the character 'D'      */

   ul1 = 0;                                    /* test format string of    */
   i   = fscanf (f1, "D %12ldm", &ul1);        /*   max. field width of 12,*/
   if (i != 1)                                 /*   long variable expected,*/
       goto Fail;                              /*   character m must appear*/
   if (ul1 != 4294967295u)                     /*   after digits read      */
       goto Fail;

   ul1 = 0;                                    /* test format string of    */
   i  = fscanf (f1, "%6lu%u", &ul1, &ui1);     /*   max. field width of 6, */
   if (i != 2)                                 /*   long variable expected,*/
       goto Fail;                              /*   followed by simple fmt */
   if ((ul1 != 327677) || (ui1 != 22))         /*   for integer            */
       goto Fail;

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.8.0.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.2\n");
   return;

Fail1:
   printf ("Unable to open input file for Conformance Test 17.8.0.2\n");
   return;

Fail2:
   printf ("Unable to close input file for Conformance Test 17.8.0.2\n");
   return;
  }
