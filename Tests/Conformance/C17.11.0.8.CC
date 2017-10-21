/* Conformance Test 17.11.0.8:  Verification of fprintf, printf, sprintf:  */
/*                              f format code                              */

#include <stdio.h>

main ()
  {
   FILE     *f1;
   int      i;
   int      i2, i3;
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


   fl1 = 45.0;
   d1  = 123.456e-2;
   e1  = 99.999;


   /* Write formatted output as string to the output files and sstring. */

   i = fprintf (f1, " %# +012.7f  %+-8.f  %# 011lf  T\n", d1, fl1, e1);
   if (i != 40)
       goto Fail;

   i = printf (" %# +012.7f  %+-8.f  %# 011lf  T\n", d1, fl1, e1);
   if (i != 40)
       goto Fail;

   i = sprintf (sstring, " %# +012.7f  %+-8.f  %# 011lf  T\n", d1, fl1, e1);
   if (i != 40)
       goto Fail;


   /* Check the string written. */

   rewind (f1);
   i = fscanf (f1, "%39c", string);
   if (i != 1)
       goto Fail3;
   string [39] = '\0';
   if (strcmp (string, " +001.2345600  +45        099.999000  T"))
       goto Fail;

   rewind (stdout);
   i = fscanf (stdout, "%39c", string);
   if (i != 1)
       goto Fail3;
   string [39] = '\0';
   if (strcmp (string, " +001.2345600  +45        099.999000  T"))
       goto Fail;

   if (strcmp (sstring, " +001.2345600  +45        099.999000  T\n"))
       goto Fail;


   fclose(stdout);                             /* redirect stdout to screen */

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.11.0.8\n");
   return;

Fail:
   fprintf (stderr, "Failed Conformance Test 17.11.0.8\n");
   return;

Fail1:
   fprintf (stderr, "Unable to open output file for Conformance Test 17.11.0.8\n");
   return;

Fail2:
   fprintf (stderr, "Unable to close output file for Conformance Test 17.11.0.8\n");
   return;

Fail3:
   fprintf (stderr, "Unable to read output file for Conformance Test 17.11.0.8\n");
   return;

Fail4:
   fprintf (stderr, "Unable to redirect stdout for Conformance Test 17.11.0.8\n");
   return;
  }
