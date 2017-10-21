/* Conformance Test 17.8.0.10:  Verification of sscanf, u format code */

#include <stdio.h>

main ()
  {
   char string [] = "  327678   D    4294967295m   32767722 ";
   int   i;
   unsigned short us1;
   unsigned int   ui1;
   unsigned long  ul1;


   ui1 = 2;                                    /* test format string of no */
   i   = sscanf (string, "%*05hu8");           /*   assignment, max. field */
   if (i != 0)                                 /*   width of 5, h ignored, */
       goto Fail;                              /*   character 8 must appear*/
   if (ui1 != 2)                               /*   after 5 digits read    */
       goto Fail;

   i = sscanf (&string [8], "%u", &ui1);       /* test "plain vanilla" fmt */
   if (i != 0)                                 /*   string; data contains  */
       goto Fail;                              /*   the character 'D'      */

   ul1 = 0;                                    /* test fmt string of max   */
   i   = sscanf (&string [11], " D %12ldm", &ul1); /*   field width of 12, */
   if (i != 1)                                 /*   long variable expected,*/
       goto Fail;                              /*   character m must appear*/
   if (ul1 != 4294967295u)                     /*   after digits read      */
       goto Fail;

   ul1 = 0;                                    /* test fmt string of max   */
   i  = sscanf (&string [27], "%6lu%u", &ul1, &ui1);  /* field width of 6, */
   if (i != 2)                                 /*   long variable expected,*/
       goto Fail;                              /*   followed by simple fmt */
   if ((ul1 != 327677) || (ui1 != 22))         /*   for integer            */
       goto Fail;

   printf ("Passed Conformance Test 17.8.0.10\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.10\n");
   return;
  }
