/* Conformance Test 17.8.0.4:  Verification of fscanf, x,X format codes */

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
   fprintf(f1, "     327678  0x  D    0xFFFFFFFFm   0x7fEd0X10");
   rewind(f1);

   us1 = 2;                                    /* test format string of no */
   i   = fscanf (f1, "%*05hx8");               /*   assignment, max. field */
   if (i != 0)                                 /*   width of 5, h ignored, */
       goto Fail;                              /*   character 8 must appear*/
   if (us1 != 2)                               /*   after 5 digits read    */
       goto Fail;

   i = fscanf (f1, "%X", &ui1);                /* test "plain vanilla" fmt */
   if (i != 1)                                 /*   string; data contains  */
       goto Fail;                              /*   the characters 0x      */
   if (ui1 != 0)
       goto Fail;

   ul1 = 0;                                    /* test format string of    */
   i   = fscanf (f1, " D %12lxm", &ul1);       /*   max. field width of 12,*/
   if (i != 1)                                 /*   long variable expected,*/
       goto Fail;                              /*   character m must appear*/
   if (ul1 != 4294967295u)                     /*   after digits read      */
       goto Fail;

   ul1 = 0;                                    /* test format string of    */
   i  = fscanf (f1, "%6lx%x", &ul1, &ui1);     /*   max. field width of 6, */
   if (i != 2)                                 /*   long variable expected,*/
       goto Fail;                              /*   followed by simple fmt */
   if ((ul1 != 0x7FED) || (ui1 != 16))         /*   for integer            */
       goto Fail;

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.8.0.4\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.4\n");
   return;

Fail1:
   printf ("Unable to open input file for Conformance Test 17.8.0.4\n");
   return;

Fail2:
   printf ("Unable to close input file for Conformance Test 17.8.0.4\n");
   return;
  }
