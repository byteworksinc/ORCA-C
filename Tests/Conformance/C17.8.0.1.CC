/* Conformance Test 17.8.0.1:  Verification of fscanf, d format code */

#include <stdio.h>

int main (void)
  {
   FILE *f1;
   short i1, i3;
   int   i;
   int   i2;
   long  L1;
   char  ch;


   f1 = fopen ("3/tmp", "wb+");                /* open input file for test */
   if (f1 == NULL)
       goto Fail1;
   fprintf(f1, "    -327678   -0   -002147483647A   327677-22  123*\r");
   rewind(f1);

   i1 = 0;                                     /* test format string of no */
   i  = fscanf (f1, "%*06hd8");                /*   assignment, max. field */
   if (i != 0)                                 /*   width of 6, h ignored, */
       goto Fail;                              /*   character 8 must appear*/
   if (i1 != 0)                                /*   after 5 digits read    */
       goto Fail;

   i2 = 15;                                    /* test "plain vanilla" fmt */
   i  = fscanf (f1, "%d", &i2);                /*   string; data contains  */
   if (i != 1)                                 /*   "-0"                   */
       goto Fail;
   if (i2 != 0)
       goto Fail;

   L1 = 0;                                     /* test format string of    */
   i  = fscanf (f1, "%13ldA", &L1);            /*   max. field width of 13,*/
   if (i != 1)                                 /*   long variable expected,*/
       goto Fail;                              /*   character A must appear*/
   if (L1 != -2147483647)                      /*   after digits read      */
       goto Fail;

   L1 = 0;                                     /* test format string of    */
   i  = fscanf (f1, "%6ld%d", &L1, &i2);       /*   max. field width of 6, */
   if (i != 2)                                 /*   long variable expected,*/
       goto Fail;                              /*   followed by simple fmt */
   if ((L1 != 327677) || (i2 != -22))          /*   for integer            */
       goto Fail;

   i3 = 4;                                     /* test format string of    */
   i  = fscanf (f1, "%4hd", &i3);              /*   max. field width of 4, */
   if (i != 1)                                 /*   short variable expectd.*/
       goto Fail;                              /*   * appears in input as  */
   if (i3 != 123)                              /*   4th char.              */
       goto Fail;

   i = fscanf (f1, "%c", &ch);                 /* Ensure offending * has   */
   if (i != 1)                                 /*   been left in input.    */
       goto Fail;
   if (ch != '*')
       goto Fail;

   i = fscanf (f1, "%c", &ch);                 /* Ensure fscanf returns EOF*/
   if (i != 1)                                 /*   when EOF encountered.  */
       goto Fail;
   if (ch != '\r')
       goto Fail;
   fgetc(f1);
   i = fscanf (f1, "%c", &ch);
   if (i != EOF)
       goto Fail;

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.8.0.1\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 17.8.0.1\n");
   return 0;

Fail1:
   printf ("Unable to open input file for Conformance Test 17.8.0.1\n");
   return 0;

Fail2:
   printf ("Unable to close input file for Conformance Test 17.8.0.1\n");
   return 0;
  }
