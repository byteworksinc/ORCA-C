/* Conformance Test 17.11.0.11: Verification of fprintf, printf, sprintf:  */
/*                              n and % format codes                       */

#include <stdio.h>

main ()
  {
   FILE     *f1;
   int      i, i1, i2;
   short    sh;
   long     l1;
   extended e1;

   char string [80], sstring [80];


   f1 = fopen ("3/tmp", "w+");                 /* open output file for test */
   if (f1 == NULL)
       goto Fail1;

   stdout = freopen ("3/tmp2", "w+", stdout);  /* redirect stdout to file */
   if (stdout == NULL)
       goto Fail4;


   e1  = 123.456e-205;
   i1  = 6;
   i2  = 16;


   /* Write formatted output as string to the output files and sstring. */

   i = fprintf (f1, "%%  %hn  %0+*.*le  %s  %%  %ln  N\n", &sh, i1, i2, e1,
                "a string", &l1);
   if (i != 48)
       goto Fail;
   if ((sh != 3) || (l1 != 44))           /* check return values for n format */
       goto Fail;

   i = printf ("%%  %hn  %0+*.*le  %s  %%  %ln  N\n", &sh, i1, i2, e1,
               "a string", &l1);
   if (i != 48)
       goto Fail;
   if ((sh != 3) || (l1 != 44))           /* check return values for n format */
       goto Fail;

   i = sprintf (sstring, "%%  %hn  %0+*.*le  %s  %%  %ln  N\n", &sh, i1, i2, e1,
                "a string", &l1);
   if (i != 48)
       goto Fail;
   if ((sh != 3) || (l1 != 44))           /* check return values for n format */
       goto Fail;


   /* Check the string written. */

   rewind (f1);
   i = fscanf (f1, "%47c", string);
   if (i != 1)
       goto Fail3;
   string [47] = '\0';
   if (strcmp (string, "%    +1.2345599999999999e-203  a string  %    N"))
       goto Fail;

   rewind (stdout);
   i = fscanf (stdout, "%47c", string);
   if (i != 1)
       goto Fail3;
   string [47] = '\0';
   if (strcmp (string, "%    +1.2345599999999999e-203  a string  %    N"))
       goto Fail;

   if (strcmp (sstring, "%    +1.2345599999999999e-203  a string  %    N\n"))
       goto Fail;


   fclose(stdout);                             /* redirect stdout to screen */

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.11.0.11\n");
   return;

Fail:
   fprintf (stderr, "Failed Conformance Test 17.11.0.11\n");
   return;

Fail1:
   fprintf (stderr, "Unable to open output file for Conformance Test 17.11.0.11\n");
   return;

Fail2:
   fprintf (stderr, "Unable to close output file for Conformance Test 17.11.0.11\n");
   return;

Fail3:
   fprintf (stderr, "Unable to read output file for Conformance Test 17.11.0.11\n");
   return;

Fail4:
   fprintf (stderr, "Unable to redirect stdout for Conformance Test 17.11.0.11\n");
   return;
  }
