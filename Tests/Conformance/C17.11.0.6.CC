/* Conformance Test 17.11.0.6:  Verification of fprintf, printf, sprintf:  */
/*                              s format code                              */

#include <stdio.h>
#include <string.h>

int main (void)
  {
   FILE *f1;
   int   i, j, k;
   char  sstring [80];
   char  string [80], arg1 [] = "first string argument",
                      arg2 [] = "second string argument  ";


   f1 = fopen ("3/tmp", "w+");                 /* open output file for test */
   if (f1 == NULL)
       goto Fail1;

   stdout = freopen ("3/tmp2", "w+", stdout);  /* redirect stdout to a file */
   if (stdout == NULL)
       goto Fail4;


   j = 15;
   k = 30;


   /* Write formatted output as string to the output files and sstring. */

   i = fprintf (f1, " %+ -10.10s  %15.7s  %*.*s  %s  E\n",
                arg1, arg1, j, k, arg2,  "very short string");
   if (i != 77)
       goto Fail;

   i = printf (" %+ -10.10s  %15.7s  %*.*s  %s  E\n",
               arg1, arg1, j, k, arg2,  "very short string");
   if (i != 77)
       goto Fail;

   i = sprintf (sstring, " %+ -10.10s  %15.7s  %*.*s  %s  E\n",
                arg1, arg1, j, k, arg2,  "very short string");
   if (i != 77)
       goto Fail;


   /* Check the string written. */

   rewind (f1);
   i = fscanf (f1, "%76c", string);
   if (i != 1)
       goto Fail3;
   string [76] = '\0';
   if (strcmp (string, " first stri          first s  second string argument  \
  very short string  E"))
       goto Fail;

   rewind (stdout);
   i = fscanf (stdout, "%76c", string);
   if (i != 1)
       goto Fail3;
   string [76] = '\0';
   if (strcmp (string, " first stri          first s  second string argument  \
  very short string  E"))
       goto Fail;

   if (strcmp (sstring, " first stri          first s  second string argument  \
  very short string  E\n"))
       goto Fail;


   fclose(stdout);                             /* redirect stdout to screen */

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.11.0.6\n");
   return 0;

Fail:
   fprintf (stderr, "Failed Conformance Test 17.11.0.6\n");
   return 0;

Fail1:
   fprintf (stderr, "Unable to open output file for Conformance Test 17.11.0.6\n");
   return 0;

Fail2:
   fprintf (stderr, "Unable to close output file for Conformance Test 17.11.0.6\n");
   return 0;

Fail3:
   fprintf (stderr, "Unable to read output file for Conformance Test 17.11.0.6\n");
   return 0;

Fail4:
   fprintf (stderr, "Unable to redirect stdout for Conformance Test 17.11.0.6\n");
   return 0;
  }
