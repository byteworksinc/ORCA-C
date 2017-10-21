/* Conformance Test 17.8.0.11:  Verification of sscanf, o format code */

#include <stdio.h>

main ()
  {
   char string [] = "  777778   D    37777777777m   117777526 ";
   int   i;
   unsigned short us1;
   unsigned int   ui1;
   unsigned long  ul1;


   us1 = 2;                                    /* test format string of no */
   i   = sscanf (string, "%*05ho8");           /*   assignment, max. field */
   if (i != 0)                                 /*   width of 5, h ignored, */
       goto Fail;                              /*   character 8 must appear*/
   if (us1 != 2)                               /*   after 5 digits read    */
       goto Fail;

   i = sscanf (&string [9], "%o", &ui1);       /* test "plain vanilla" fmt */
   if (i != 0)                                 /*   string; data contains  */
       goto Fail;                              /*   the character 'D'      */

   ul1 = 0;                                    /* test fmt string of max   */
   i   = sscanf (&string [11], "D %12lom", &ul1);   /*  field width of 12, */
   if (i != 1)                                 /*   long variable expected,*/
       goto Fail;                              /*   character m must appear*/
   if (ul1 != 4294967295u)                     /*   after digits read      */
       goto Fail;

   ul1 = 0;                                    /* test fmt string of max   */
   i  = sscanf (&string [31], "%7lo%o", &ul1, &ui1); /*  field width of 6, */
   if (i != 2)                                 /*   long variable expected,*/
       goto Fail;                              /*   followed by simple fmt */
   if ((ul1 != 327677) || (ui1 != 22))         /*   for integer            */
       goto Fail;

   printf ("Passed Conformance Test 17.8.0.11\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.11\n");
   return;
  }
