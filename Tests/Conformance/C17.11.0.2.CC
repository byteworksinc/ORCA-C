/* Conformance Test 17.11.0.2:  Verification of fprintf, sprintf, printf:  */
/*                              u format code                              */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int   i, i1, i2;
   unsigned int  ui1, ui2;
   unsigned long ul1;
   char  string [80], sstring [80];


   f1 = fopen ("3/tmp", "w+");                 /* open output file for test */
   if (f1 == NULL)
       goto Fail1;

   stdout = freopen ("3/tmp2", "w+", stdout);  /* redirect stdout to a file */
   if (stdout == NULL)
       goto Fail4;


   ui1 = 65535;
   ui2 = 0;
   ul1 = 4294967295u;
   i1  = 12;
   i2  = 16;

   /* Write formatted output as string to the output files and sstring. */

   i = fprintf (f1, " %-11.10hu  %# +07.4lu  %.0u  %-*.*lu  A\n",
                ui1, (long) ui1, ui2, i1, i2, ul1);
   if (i != 45)
       goto Fail;

   i = printf (" %-11.10hu  %# +07.4lu  %.0u  %-*.*lu  A\n",
               ui1, (long) ui1, ui2, i1, i2, ul1);
   if (i != 45)
       goto Fail;

   i = sprintf (sstring, " %-11.10hu  %# +07.4lu  %.0u  %-*.*lu  A\n",
                ui1, (long) ui1, ui2, i1, i2, ul1);
   if (i != 45)
       goto Fail;


   /* Check the string written. */

   rewind (f1);
   i = fscanf (f1, "%44c", string);
   if (i != 1)
       goto Fail3;
   string [44] = '\0';
   i = fprintf (f1, " %-11.10hu  %# +07.4lu  %.0u  %-*.*lu  A\n",
                ui1, (long) ui1, ui2, i1, i2, ul1);
   if (strcmp (string, " 0000065535   +065535    0000004294967295  A"))
       goto Fail;

   rewind (stdout);
   i = fscanf (stdout, "%44c", string);
   if (i != 1)
       goto Fail3;
   string [44] = '\0';
   if (strcmp (string, " 0000065535   +065535    0000004294967295  A"))
       goto Fail;

   if (strcmp (sstring, " 0000065535   +065535    0000004294967295  A\n"))
       goto Fail;


   fclose(stdout);                             /* redirect stdout to screen */

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.11.0.2\n");
   return;

Fail:
   fprintf (stderr, "Failed Conformance Test 17.11.0.2\n");
   return;

Fail1:
   fprintf (stderr,
      "Unable to open output file for Conformance Test 17.11.0.2\n");
   return;

Fail2:
   fprintf (stderr, "Unable to close output file for Conformance Test 17.11.0.2\n");
   return;

Fail3:
   fprintf (stderr,
      "Unable to read output file for Conformance Test 17.11.0.2\n");
   return;

Fail4:
   fprintf (stderr,
      "Unable to redirect stdout for Conformance Test 17.11.0.2\n");
   return;
  }
