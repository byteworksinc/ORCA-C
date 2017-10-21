/* Special Conformance Test 17.6.0.1:  Verification of fgetc, getc, getchar, */
/*                                     and ungetc with standard input        */
/*                                                                           */
/* The first action of the test is to verify that standard input is working. */
/* The tester will be prompted for a string three times (once each for fgetc,*/
/* getc, and getchar); this string will then be echoed to standard out and to*/
/* standard error out.  The tester needs to verify that the output string is */
/* correct.                                                                  */
/*                                                                           */
/* The test will then redirect standard input to a temporary file created on */
/* the work prefix.  The tester needs to verify that the characters sent to  */
/* standard output and standard error output are the lower case alphabetic   */
/* characters.                                                               */
/*                                                                           */
/* Finally, standard input is reset to the keyboard.  The tester will be     */
/* prompted for a new string to be entered from the keyboard.  The tester    */
/* needs to verify that the string is correctly echoed to the screen.        */

#include <stdlib.h>
#include <stdio.h>

main ()
  {
   int  i, j;
   char s [255], ch;
   FILE *f1, *saveStdin;


 /* This part of the test that standard input and standard output are working */

   printf ("Please enter a string\n");         /* test fgetc with standard in */
   j = 0;
   while ((i = fgetc (stdin)) != '\n')
     {
       if (i == EOF)
           goto Fail3;
       s [j++] = i;
     }
   s [j] = '\0';
   printf ("The string entered is:\n");
   i = fputs (s, stdout);
   if (i)
       goto Fail4;
   printf ("\n");
   i = fputs (s, stderr);
   if (i)
       goto Fail5;
   printf ("\n");

   printf ("Please enter a string\n");         /* test getc with standard in */
   j = 0;
   while ((i = getc (stdin)) != '\n')
     {
       if (i == EOF)
           goto Fail3;
       s [j++] = i;
     }
   s [j] = '\0';
   printf ("The string entered is:\n");
   i = fputs (s, stdout);
   if (i)
       goto Fail4;
   printf ("\n");
   i = fputs (s, stderr);
   if (i)
       goto Fail5;
   printf ("\n");

   printf ("Please enter a string\n");         /* test getchar */
   j = 0;
   while ( (i = getchar ()) != '\n' )
     {
       if (i == EOF)
           goto Fail3;
       s [j++] = i;
     }
   s [j] = '\0';
   printf ("The string entered is:\n");
   i = fputs (s, stdout);
   if (i)
       goto Fail4;
   printf ("\n");
   i = fputs (s, stderr);
   if (i)
       goto Fail5;
   printf ("\n");


   /* Now test fgetc, getc, and getchar by redirecting standard input. */

   f1 = fopen ("3/tmp", "w");                          /* create new file */
   if (f1 == NULL)
       goto Fail;
   for (ch = 'a', i = 0; i < 26; i++)
     {
       j = fputc (ch, f1);
       if ( (char) j != ch )
           goto Fail2;
       ch++;
     }
   j = fputc ('\n', f1);
   if (j != '\n')
       goto Fail2;

   saveStdin = stdin;
   stdin = freopen ("3/tmp", "r", f1);             /* reassign standard in */
   if (stdin == NULL)
       goto Fail1;

   j = 0;                                          /* read file with fgetc */
   while ( (i = fgetc (stdin)) != EOF) {
       putchar(i);
       s [j++] = i;
       }
   s [j] = '\0';
   if (! feof (stdin) )
       goto Fail3;
   printf ("The string read from the temp file is:\n");
   i = fputs (s, stdout);
   if (i)
       goto Fail4;
   i = fputs (s, stderr);
   if (i)
       goto Fail5;

   rewind (stdin);                                 /* read file with getc  */
   j = 0;
   while ( (i = getc (stdin)) != EOF)
       s [j++] = i;
   s [j] = '\0';
   if (! feof (stdin) )
       goto Fail3;
   printf ("The string read from the temp file is:\n");
   i = fputs (s, stdout);
   if (i)
       goto Fail4;
   i = fputs (s, stderr);
   if (i)
       goto Fail5;

   rewind (stdin);                                 /* read file with getchar */
   j = 0;
   while ( (i = getchar ()) != EOF)
       s [j++] = i;
   s [j] = '\0';
   if (! feof (stdin) )
       goto Fail3;
   printf ("The string read from the temp file is:\n");
   i = fputs (s, stdout);
   if (i)
       goto Fail4;
   i = fputs (s, stderr);
   if (i)
       goto Fail5;


   /* Now reset standard input and ensure it's ok. */

   stdin = saveStdin;                          /* reassign standard in        */
   printf ("Please enter a string\n");         /* read standard in with fgetc */
   j = 0;
   while ((i = fgetc (stdin)) != '\n')
     {
       if (i == EOF)
           goto Fail3;
       s [j++] = i;
     }
   s [j] = '\0';
   printf ("The string entered is:\n");
   i = fputs (s, stdout);
   if (i)
       goto Fail4;
   printf ("\n");
   i = fputs (s, stderr);
   if (i)
       goto Fail5;
   printf ("\n");

   printf ("Please enter a string\n");         /* read standard in with getc */
   j = 0;
   while ((i = getc (stdin)) != '\n')
     {
       if (i == EOF)
           goto Fail3;
       s [j++] = i;
     }
   s [j] = '\0';
   printf ("The string entered is:\n");
   i = fputs (s, stdout);
   if (i)
       goto Fail4;
   printf ("\n");
   i = fputs (s, stderr);
   if (i)
       goto Fail5;
   printf ("\n");

   printf ("Please enter a string\n");       /* read standard in with getchar */
   j = 0;
   while ( (i = getchar ()) != '\n' )
     {
       if (i == EOF)
           goto Fail3;
       s [j++] = i;
     }
   s [j] = '\0';
   printf ("The string entered is:\n");
   i = fputs (s, stdout);
   if (i)
       goto Fail4;
   printf ("\n");
   i = fputs (s, stderr);
   if (i)
       goto Fail5;
   printf ("\n");

   return;

Fail:
   perror ("File open failure in Special Conformance Test 17.6.0.1 ");
   exit (0);

Fail1:
   printf ("Error when reopening stream\n");
   exit (0);

Fail2:
   printf ("Error when writing file\n");
   exit (0);

Fail3:
   printf ("Error when reading from standard in\n");
   exit (0);

Fail4:
   printf ("Error when writing to standard out\n");
   exit (0);

Fail5:
   printf ("Error when writing to standard error out\n");
   exit (0);
  }
