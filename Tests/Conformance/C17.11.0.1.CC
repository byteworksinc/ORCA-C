/* Conformance Test 17.11.0.1:  Verification of fprintf, printf, sprintf:  */
/*                              d, i format codes                          */

#include <string.h>
#include <stdio.h>

main ()
  {
   FILE *f1;
   short i1;
   int   i;
   int   i2, i3;
   long  L1;
   char  string [80], sstring [80];


   f1 = fopen ("3/tmp", "w+");                 /* open output file for test */
   if (f1 == NULL)
       goto Fail1;

   stdout = freopen ("3/tmp2", "w+", stdout);  /* redirect stdout to a file */
   if (stdout == NULL)
       goto Fail4;


   i1 = 32767;
   i2 = 0;
   L1 = -32767;
   i3 = 8;

   /* Write formatted output as string to the output files and sstring. */

   i = fprintf (f1, " %-0+10.8hd  %0 10.*i  %5.d  %10.8li  %#-*li  M\n",
                i1, i3, i1, i2, L1, i3, L1);
   if (i != 56)
       goto Fail;

   i = printf (" %-0+10.8hd  %0 10.*i  %5.d  %10.8li  %#-*li  M\n",
               i1, i3, i1, i2, L1, i3, L1);
   if (i != 56)
       goto Fail;
             
   i = sprintf (sstring, " %-0+10.8hd  %0 10.*i  %5.d  %10.8li  %#-*li  M\n",
                i1, i3, i1, i2, L1, i3, L1);
   if (i != 56)
       goto Fail;
                      

   /* Check the string written. */

   rewind (f1);
   i = fscanf (f1, "%55c", string);
   if (i != 1)
       goto Fail3;
   string [55] = '\0';              
   if (strcmp (string, " +000032767   000032767          -00032767\
  -32767    M"))
       goto Fail;
                      
   rewind (stdout);
   i = fscanf (stdout, "%55c", string);
   if (i != 1)
       goto Fail3;
   string [55] = '\0';
   if (strcmp (string, " +000032767   000032767          -00032767\
  -32767    M"))
       goto Fail;

   if (strcmp (sstring, " +000032767   000032767          -00032767\
  -32767    M\n"))
       goto Fail;

                      
   fclose(stdout);                             /* redirect stdout to screen */

   i = fclose (f1);                            /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.11.0.1\n");
   return;

Fail:
   fprintf (stderr, "Failed Conformance Test 17.11.0.1\n");
   return;

Fail1:
   fprintf (stderr, "Unable to open output file for Conformance Test 17.11.0.1\n");
   return;

Fail2:
   fprintf (stderr, "Unable to close output file for Conformance Test 17.11.0.1\n");
   return;

Fail3:
   fprintf (stderr, "Unable to read output file for Conformance Test 17.11.0.1\n");
   return;

Fail4:
   fprintf (stderr, "Unable to redirect stdout for Conformance Test 17.11.0.1\n");
   return;
  }
