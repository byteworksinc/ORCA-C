/*                                                                           */
/* Special Conformance Test 17.2.0.2:  Verification of fflush                */
/*                                                                           */
/* Other files needed: spc17.202.exec - EXEC file which flushes the contents */
/*                                      of 12 data files to the printer      */
/*                     spc17.2.0.a - spc17.2.0.l - data files for the test   */
/*                                                                           */
/* Tester needs to verify that the 12 files named spc17.2.0.a - spc17.2.0.l, */
/* and located on the work prefix, are dumped to the printer                 */
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
   i = fputs ("This is file 3/spc17.2.0.a", f1);
   if (i == EOF)
       goto Fail2;
   i = fflush (f1);
   if (i == EOF)
       goto Fail3;

   count++;
   f2 = fopen (fn2, "a");              /* open for appending */
   if (f2 == NULL)
       goto Fail;
   i = fputs ("This is file 3/spc17.2.0.b", f2);
   if (i == EOF)
       goto Fail2;
   i = fflush (f2);
   if (i == EOF)
       goto Fail3;

   count++;
   f3 = fopen (fn3, "a");              /* open for appending */
   if (f3 == NULL)
       goto Fail;
   i = fputs ("This is file 3/spc17.2.0.c", f3);
   if (i == EOF)
       goto Fail2;
   i = fflush (f3);
   if (i == EOF)
       goto Fail3;

   count++;
   f4 = fopen (fn4, "w+");             /* open for update, starting at */
   if (f4 == NULL)                     /*   beginning of file          */
       goto Fail;
   i = fputs ("This is file 3/spc17.2.0.d", f4);
   if (i == EOF)
       goto Fail2;
   i = fflush (f4);
   if (i == EOF)
       goto Fail3;

   count++;
   f5 = fopen (fn5, "w+");             /* open for update, clearing file */
   if (f5 == NULL)                     /*   contents                     */
       goto Fail;
   i = fputs ("This is file 3/spc17.2.0.e", f5);
   if (i == EOF)
       goto Fail2;
   i = fflush (f5);
   if (i == EOF)
       goto Fail3;

   count++;
   f6 = fopen (fn6, "a+");             /* open for update, starting at */
   if (f6 == NULL)                     /*   end of file                */
       goto Fail;
   i = fputs ("This is file 3/spc17.2.0.f", f6);
   if (i == EOF)
       goto Fail2;
   i = fflush (f6);
   if (i == EOF)
       goto Fail3;

   /* Open two more files, then shut 4 open ones before opening the   */
   /* last four files.  These files will be open in "binary" mode.    */

   count++;
   f7 = fopen (fn7, "wb");             /* open binary file for writing */
   if (f7 == NULL)
       goto Fail;
   i = fprintf (f7, "%f", -43.876);
   if (i == EOF)
       goto Fail2;
   i = fflush (f7);
   if (i == EOF)
       goto Fail3;

   count++;
   f8 = fopen (fn8, "wb");             /* open binary file for writing */
   if (f8 == NULL)
       goto Fail;
   i = fprintf (f8, "%d", 32767);
   if (i == EOF)
       goto Fail2;
   i = fflush (f8);
   if (i == EOF)
       goto Fail3;

   count++;
   i = fclose (f1);                    /* close the first four files   */
   if (i == EOF)
       goto Fail4;

   count++;
   i = fclose (f2);
   if (i == EOF)
       goto Fail4;

   count++;
   i = fclose (f3);
   if (i == EOF)
       goto Fail4;

   count++;
   i = fclose (f4);
   if (i == EOF)
       goto Fail4;

   count++;
   f1 = fopen (fn9, "ab");             /* open binary file for appending */
   if (f1 == NULL)
       goto Fail;
   i = fprintf (f1, "%e", 23.8e+90);
   if (i == EOF)
       goto Fail2;
   i = fflush (f1);
   if (i == EOF)
       goto Fail3;

   count++;
   f2 = fopen (fn10, "wb+");           /* open binary file for update,    */
   if (f2 == NULL)                     /*   starting at beginning of file */
       goto Fail;
   i = fprintf (f2, "%c", 0x07);
   if (i == EOF)
       goto Fail2;
   i = fflush (f2);
   if (i == EOF)
       goto Fail3;

   count++;
   f3 = fopen (fn11, "wb+");           /* open binary file for update,    */
   if (f3 == NULL)                     /*   clearing file contents first  */
       goto Fail;
   i = fprintf (f3, "%%");
   if (i == EOF)
       goto Fail2;
   i = fflush (f3);
   if (i == EOF)
       goto Fail3;

   count++;
   f4 = fopen (fn12, "ab+");           /* open binary file for update,    */
   if (f4 == NULL)                     /*   starting at end of file       */
       goto Fail;
   i = fprintf (f4, "%d", count);
   if (i == EOF)
       goto Fail2;
   i = fflush (f4);
   if (i == EOF)
       goto Fail3;

   count++;
   i = fclose (f1);                    /* close all of the open files  */
   if (i == EOF)
       goto Fail4;

   count++;
   i = fclose (f2);
   if (i == EOF)
       goto Fail4;

   count++;
   i = fclose (f3);
   if (i == EOF)
       goto Fail4;

   count++;
   i = fclose (f4);
   if (i == EOF)
       goto Fail4;

   count++;
   i = fclose (f5);
   if (i == EOF)
       goto Fail4;

   count++;
   i = fclose (f6);
   if (i == EOF)
       goto Fail4;

   count++;
   i = fclose (f7);
   if (i == EOF)
       goto Fail4;

   count++;
   i = fclose (f8);
   if (i == EOF)
       goto Fail4;

   printf ("Passed Special Conformance Test 17.2.0.2 ");
   return;

Fail:
   perror ("File open failure in Special Conformance Test 17.2.0.2 ");
   goto Out;

Fail2:
   printf ("Error when writing to file\n");
   goto Out;

Fail3:
   printf ("Error when flushing file\n");
   goto Out;

Fail4:
   printf ("Error when closing file\n");

Out:
   printf ("count = %d\n", count);
  }
