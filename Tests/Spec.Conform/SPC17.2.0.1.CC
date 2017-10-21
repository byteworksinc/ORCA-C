/*                                                                           */
/* Special Conformance Test 17.2.0.1:  Verification of fopen and fclose:     */
/*                                     creating new files                    */
/*                                                                           */
/* Tester needs to verify that the 12 files named spc17.2.0.a - spc17.2.0.l  */
/* are created on the work prefix.                                           */
/*                                                                           */

#include <stdio.h>

main ()
  {
   int i, count = 0;

   FILE *f1, *f2, *f3, *f4, *f5, *f6, *f7, *f8;       /* must be able to open */
                                                      /*   8 files at a time  */

   char fn1  [14] = "3/spc17.2.0.a";                  /* define filenames     */
   char fn2  [14] = "3/spc17.2.0.b";
   char fn3  [14] = "3/spc17.2.0.c";
   char fn4  [14] = "3/spc17.2.0.d";
   char fn5  [14] = "3/spc17.2.0.e";
   char fn6  [14] = "3/spc17.2.0.f";
   char fn7  [14] = "3/spc17.2.0.g";
   char fn8  [14] = "3/spc17.2.0.h";
   char fn9  [14] = "3/spc17.2.0.i";
   char fn10 [14] = "3/spc17.2.0.j";
   char fn11 [14] = "3/spc17.2.0.k";
   char fn12 [14] = "3/spc17.2.0.l";


   count++;
   f1 = fopen (fn1, "w");              /* open for writing */
   if (f1 == NULL)
       goto Fail;

   count++;
   f2 = fopen (fn2, "w");
   if (f2 == NULL)
       goto Fail;

   count++;
   f3 = fopen (fn3, "a");              /* open for appending */
   if (f3 == NULL)
       goto Fail;

   count++;
   f4 = fopen (fn4, "w+");             /* open for update, starting at */
   if (f4 == NULL)                     /*   beginning of file          */
       goto Fail;

   count++;
   f5 = fopen (fn5, "w+");             /* open for update, clearing file */
   if (f5 == NULL)                     /*   contents                     */
       goto Fail;

   count++;
   f6 = fopen (fn6, "a+");             /* open for update, starting at */
   if (f6 == NULL)                     /*   end of file                */
       goto Fail;

   /* Open two more files, then shut 4 open ones before opening the   */
   /* last four files.  These files will be open in "binary" mode.    */

   count++;
   f7 = fopen (fn7, "wb");             /* open binary file for writing */
   if (f7 == NULL)
       goto Fail;

   count++;
   f8 = fopen (fn8, "wb");
   if (f8 == NULL)
       goto Fail;

   count++;
   i = fclose (f1);                    /* close the first four files   */
   if (i == EOF)
       goto Fail2;

   count++;
   i = fclose (f2);
   if (i == EOF)
       goto Fail2;

   count++;
   i = fclose (f3);
   if (i == EOF)
       goto Fail2;

   count++;
   i = fclose (f4);
   if (i == EOF)
       goto Fail2;

   count++;
   f1 = fopen (fn9, "ab");             /* open binary file for appending */
   if (f1 == NULL)
       goto Fail;

   count++;
   f2 = fopen (fn10, "wb+");           /* open binary file for update,    */
   if (f2 == NULL)                     /*   starting at beginning of file */
       goto Fail;

   count++;
   f3 = fopen (fn11, "wb+");           /* open binary file for update,    */
   if (f3 == NULL)                     /*   clearing file contents first  */
       goto Fail;

   count++;
   f4 = fopen (fn12, "ab+");           /* open binary file for update,    */
   if (f4 == NULL)                     /*   starting at end of file       */
       goto Fail;

   count++;
   i = fclose (f1);                    /* close all of the open files  */
   if (i == EOF)
       goto Fail2;

   count++;
   i = fclose (f2);
   if (i == EOF)
       goto Fail2;

   count++;
   i = fclose (f3);
   if (i == EOF)
       goto Fail2;

   count++;
   i = fclose (f4);
   if (i == EOF)
       goto Fail2;

   count++;
   i = fclose (f5);
   if (i == EOF)
       goto Fail2;

   count++;
   i = fclose (f6);
   if (i == EOF)
       goto Fail2;

   count++;
   i = fclose (f7);
   if (i == EOF)
       goto Fail2;

   count++;
   i = fclose (f8);
   if (i == EOF)
       goto Fail2;

   printf ("Passed Special Conformance Test 17.2.0.1 ");
   return;

Fail:
   printf ("count = %d\n", count);
   perror ("File creation failure in Special Conformance Test 17.2.0.1 ");
   return;

Fail2:
   printf ("count = %d\n", count);
   printf ("Error when closing file");
  }
