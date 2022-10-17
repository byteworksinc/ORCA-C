/* Conformance Test 17.11.0.5:  Verification of fprintf, printf, sprintf:  */
/*                              c format code                              */

#include <stdio.h>
#include <string.h>

int main (void)
  {
   FILE *f1;
   int   i, i1, i2;
   unsigned int  ui1, ui2;
   char  string [80], sstring [80];


   f1 = fopen ("3/tmp", "w+");                 /* open output file for test */
   if (f1 == NULL)
       goto Fail1;

   stdout = freopen ("3/tmp2", "w+", stdout);  /* redirect stdout to a file */
   if (stdout == NULL)
       goto Fail4;


   ui1 = 'a';
   ui2 = 'b';
   i1  = 3;
   i2  = 2;


   /* Write formatted output as string to the output file. */

   i = fprintf (f1, " %+ -10c  %5c  %c  %+ *c  D\n",
                ui1, ui1, ui2, i1, 'd');
   if (i != 30)
       goto Fail;

   i = printf (" %+ -10c  %5c  %c  %+ *c  D\n",
               ui1, ui1, ui2, i1, 'd');
   if (i != 30)
       goto Fail;

   i = sprintf (sstring, " %+ -10c  %5c  %c  %+ *c  D\n",
                ui1, ui1, ui2, i1, 'd');
   if (i != 30)
       goto Fail;


   /* Check the string written. */

   rewind (f1);
   i = fscanf (f1, "%29c", string);
   if (i != 1)
       goto Fail3;
   string [29] = '\0';
   if (strcmp (string, " a               a  b    d  D"))
       goto Fail;

   rewind (stdout);
   i = fscanf (stdout, "%29c", string);
   if (i != 1)
       goto Fail3;
   string [29] = '\0';
   if (strcmp (string, " a               a  b    d  D"))
       goto Fail;

   if (strcmp (sstring, " a               a  b    d  D\n"))
       goto Fail;


   fclose(stdout);                             /* redirect stdout to screen */

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.11.0.5\n");
   return 0;

Fail:
   fprintf (stderr, "Failed Conformance Test 17.11.0.5\n");
   return 0;

Fail1:
   fprintf (stderr, "Unable to open output file for Conformance Test 17.11.0.5\n");
   return 0;

Fail2:
   fprintf (stderr, "Unable to close output file for Conformance Test 17.11.0.5\n");
   return 0;

Fail3:
   fprintf (stderr, "Unable to read output file for Conformance Test 17.11.0.5\n");
   return 0;

Fail4:
   fprintf (stderr, "Unable to redirect stdout for Conformance Test 17.11.0.5\n");
   return 0;
  }
