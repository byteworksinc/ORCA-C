/* Conformance Test 17.11.0.10:  Verification of fprintf, printf, sprintf:  */
/*                               g,G format codes                           */

#include <stdio.h>

main ()
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


   fl1 = 9.0;
   d1  = -123.456e-20;
   e1  = 9876543210.0;
   i1  = 15;
   i2  = 8;


   /* Write formatted output as string to the output files and sstring. */

   i = fprintf (f1, " %+0 #5.g  %-0*.*G  %13.10Lg  G\n", fl1, i1, i2, d1, e1);
   if (i != 42)
       goto Fail;

   i = printf (" %+0 #5.g  %-0*.*G  %13.10Lg  G\n", fl1, i1, i2, d1, e1);
   if (i != 42)
       goto Fail;

   i = sprintf (sstring, " %+0 #5.g  %-0*.*G  %13.10Lg  G\n", fl1, i1, i2, d1, e1);
   if (i != 42)
       goto Fail;


   /* Check the string written. */

   rewind (f1);
   i = fscanf (f1, "%41c", string);
   if (i != 1)
       goto Fail3;
   string [41] = '\0';
   if (strcmp (string, " +009.  -0001.23456E-18     9876543210  G"))
       goto Fail;

   rewind (stdout);
   i = fscanf (stdout, "%41c", string);
   if (i != 1)
       goto Fail3;
   string [41] = '\0';
   if (strcmp (string, " +009.  -0001.23456E-18     9876543210  G"))
       goto Fail;

   if (strcmp (sstring, " +009.  -0001.23456E-18     9876543210  G\n"))
       goto Fail;


   fclose(stdout);                             /* redirect stdout to screen */

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.11.0.10\n");
   return;

Fail:
   fprintf (stderr, "Failed Conformance Test 17.11.0.10\n");
   return;

Fail1:
   fprintf (stderr, "Unable to open output file for Conformance Test 17.11.0.10\n");
   return;

Fail2:
   fprintf (stderr, "Unable to close output file for Conformance Test 17.11.0.10\n");
   return;

Fail3:
   fprintf (stderr, "Unable to read output file for Conformance Test 17.11.0.10\n");
   return;

Fail4:
   fprintf (stderr, "Unable to redirect stdout for Conformance Test 17.11.0.10\n");
   return;
  }
