/*                                                                           */
/* Special Conformance Test 17.2.0.3:  Verification of freopen               */
/*                                                                           */
/* Other files needed: spc17.2.0.a - spc17.2.0.d - data files for the test   */
/*                                                                           */
/* Tester needs to verify that the files named spc17.2.0.a - spc17.2.0.d,    */
/* and located on the work prefix, have previously been created with the     */
/* test Special Conformance 17.2.0.2.                                        */
/*                                                                           */
/* The first action of the test will be to open spc17.2.0.a, and print its   */
/* contents on the screen.  The tester needs to verify that the contents are */
/* correct.                                                                  */
/*                                                                           */
/* The next action is to verify that standard input is working.  The tester  */
/* will be prompted for a string; this string will then be written to both   */
/* standard out and standard error out.  The tester needs to verify that the */
/* output strings are correct.                                               */
/*                                                                           */
/* The test will then redirect standard in, standard out, and standard error */
/* out.  The contents of spc17.2.0.b will be sent to the files spc17.0.c,    */
/* the new standard out, and spc17.2.0.d, the new standard error out.   The  */
/* tester needs to verify that the three files are identical.                */
/*                                                                           */
/* Finally, standard in, standard out, and standard error out will be reset  */
/* to their original values.  The tester will be prompted for a new string   */
/* to be entered from the keyboard.  The tester needs to verify that the     */
/* string is correctly echoed to the screen twice (once for standard out and */
/* once for standard error out).                                             */
/*                                                                           */

#include <stdlib.h>
#include <stdio.h>

main ()
  {
   int i, j;
   char s [255];                                       /* input buffer */

   FILE *f1, *f2, *f3, *f4;
   FILE *saveStdin, *saveStdout, *saveStderr;

   char fn1  [14] = "3/spc17.2.0.a";                   /* define filenames */
   char fn2  [14] = "3/spc17.2.0.b";
   char fn3  [14] = "3/spc17.2.0.c";
   char fn4  [14] = "3/spc17.2.0.d";

   f1 = fopen (fn1, "r");                              /* open for reading */
   if (f1 == NULL)
       goto Fail;
   i = 0;
   while ((j = fgetc (f1)) != EOF)                     /* read successive     */
       s [i++] = (char) j;                             /*   chars into string */
   s [i] = '\0';
   printf ("This is the contents of 3/spc17.2.0.a:\n%s\n", s);

   f1 = freopen (fn2, "a+", f1);                     /* reassign file pointer */
   if (f1 == NULL)
       goto Fail2;
   i = fseek (f1, 0L, SEEK_END);                     /* move to end of file   */
   if (i)
       goto Fail5;
   i = fputs ("This is the second line of file 3/spc17.2.0.b", f1);
   if (i == EOF)
       goto Fail3;
   rewind (f1);
   i = 0;
   while ((j = fgetc (f1)) != EOF)                     /* read successive     */
       s [i++] = (char) j;                             /*   chars into string */
   s [i] = '\0';
   printf ("\nThese are the updated contents of 3/spc17.2.0.b:\n%s\n", s);


   /* This part of the test verifies reopening standard in, standard out, and */
   /* standard error out.                                                     */

   printf ("Please enter a string\n");         /* 1st verify that standard in */
   j = 0;                                      /*   standard out and standard */
   while ((i = fgetc (stdin)) != '\n')         /*   error out work            */
     {
       if (i == EOF)
           goto Fail7;
       s [j++] = i;
     }
   s [j] = '\0';
   printf ("The string entered is:\n");
   i = fputs (s, stdout);
   if (i)
       goto Fail8;
   printf ("\n");
   i = fputs (s, stderr);
   if (i)
       goto Fail9;
   printf ("\n");


   saveStdin = stdin;
   stdin = freopen (fn1, "r", f1);         /* reassign standard in */
   if (stdin == NULL)
       goto Fail2;

   f3 = fopen (fn3, "w");                  /* open stream to get new FILE ptr */
   if (f3 == NULL)
       goto Fail;
   saveStdout = stdout;
   stdout = freopen (fn3, "w", f3);        /* reassign standard out */
   if (stdout == NULL)
       goto Fail2;

   saveStderr = stderr;
   f4 = fopen (fn4, "w");                  /* open stream to get new FILE ptr */
   if (f4 == NULL)
       goto Fail;
   stderr = freopen (fn4, "w", f4);        /* reassign standard error */
   if (stderr == NULL)
       goto Fail2;

   i = fscanf (stdin, "%s", s);            /* read input string from file */
   if (i == EOF)
       goto Fail7;
   i = puts (s);                           /* write string to files */
   if (i)
       goto Fail8;
   i = fputs (s, stderr);
   if (i)
       goto Fail9;


   /* Now reset standard in, standard out, and standard error, and ensure */
   /* they're ok.                                                         */

   i = fclose (stdin);                           /* close disk files attached */
   if (i == EOF)                                 /*  to stdin, stdout, stderr */
       goto Fail4;
   i = fclose (stdout);
   if (i == EOF)
       goto Fail4;
   i = fclose (stderr);
   if (i == EOF)
       goto Fail4;

   stdin  = saveStdin;                         /* reassign standard in    */
   stdout = saveStdout;                        /* reassign standard out   */
   stderr = saveStderr;                        /* reassign standard error */

   printf ("Please enter a string\n");         /* Prompt the tester to input  */
   j = 0;                                      /*   a string & then check that*/
   while ((i = fgetc (stdin)) != '\n')         /*   it's written to stdout &  */
     {                                         /*   stderr                    */
       if (i == EOF)
           goto Fail7;
       s [j++] = i;
     }
   s [j] = '\0';
   printf ("The string entered is:\n");
   i = puts (s);
   if (i)
       goto Fail8;
   printf ("\n");
   i = fputs (s, stderr);
   if (i)
       goto Fail9;
   printf ("\n");

   printf ("Passed Special Conformance Test 17.2.0.3 ");
   return;

Fail:
   perror ("File open failure in Special Conformance Test 17.2.0.3 ");
   exit (0);

Fail2:
   printf ("Error when reopening stream\n");
   exit (0);

Fail3:
   printf ("Error when writing file\n");
   exit (0);

Fail4:
   printf ("Error when closing file\n");
   exit (0);

Fail5:
   printf ("Error when seeking file\n");
   exit (0);

Fail6:
   printf ("Error when appending to file\n");
   exit (0);

Fail7:
   printf ("Error when reading from standard in\n");
   exit (0);

Fail8:
   printf ("Error when writing to standard out\n");
   exit (0);

Fail9:
   printf ("Error when writing to standard error out\n");
   exit (0);
  }
