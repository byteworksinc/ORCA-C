/* Conformance Test 17.11.0.9:  Verification of fprintf, printf, sprintf:  */
/*                              e, E format codes                          */

#include <stdio.h>
#include <string.h>

int main (void)
  {
   FILE     *f1;
   int      i;
   int      i1, i2, i3;
   float    fl1;
   double   d1;
   extended e1;

   char string [80], sstring [80];


   f1 = fopen ("3/tmp", "w+");                 /* open output file for test */
   if (f1 == NULL)
       goto Fail1;

   stdout = freopen ("3/tmp2", "w+", stdout);  /* redirect stdout to file */
   if (stdout == NULL)
       goto Fail4;


   fl1 = 5.0;
   d1  = -4.7;
   e1  = 123.456e-205;
   i1  = 6;
   i2  = 16;


   /* Write formatted output as string to the output files and sstring. */

   i = fprintf (f1, " %0+*.*Le  %- 15E  %#0 .e  E\n", i1, i2, e1, d1, fl1);
   if (i != 55)
       goto Fail;

   i = printf (" %0+*.*Le  %- 15E  %#0 .e  E\n", i1, i2, e1, d1, fl1);
   if (i != 55)
       goto Fail;

   i = sprintf (sstring, " %0+*.*Le  %- 15E  %#0 .e  E\n", i1, i2, e1, d1, fl1);
   if (i != 55)
       goto Fail;


   /* Check the string written. */

   rewind (f1);
   i = fscanf (f1, "%54c", string);
   if (i != 1)
       goto Fail3;
   string [54] = '\0';
   if (strcmp (string, " +1.2345600000000000e-203  -4.700000E+00     5.e+00  E"))
       goto Fail;

   rewind (stdout);
   i = fscanf (stdout, "%54c", string);
   if (i != 1)
       goto Fail3;
   string [54] = '\0';
   if (strcmp (string, " +1.2345600000000000e-203  -4.700000E+00     5.e+00  E"))
       goto Fail;

   if (strcmp (sstring, " +1.2345600000000000e-203  -4.700000E+00     5.e+00  E\n"))
       goto Fail;


   fclose(stdout);                             /* redirect stdout to screen */

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.11.0.9\n");
   return 0;

Fail:
   fprintf (stderr, "Failed Conformance Test 17.11.0.9\n");
   return 0;

Fail1:
   fprintf (stderr, "Unable to open output file for Conformance Test 17.11.0.9\n");
   return 0;

Fail2:
   fprintf (stderr, "Unable to close output file for Conformance Test 17.11.0.9\n");
   return 0;

Fail3:
   fprintf (stderr, "Unable to read output file for Conformance Test 17.11.0.9\n");
   return 0;

Fail4:
   fprintf (stderr, "Unable to redirect stdout for Conformance Test 17.11.0.9\n");
   return 0;
  }
