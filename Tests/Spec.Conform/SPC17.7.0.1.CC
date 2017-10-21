/* Special Conformance Test 17.7.0.1:  Verification of gets function */
/*                                                                   */
/* The tester will be asked to enter some strings.  The strings will */
/* then be echoed to the screen.  The strings should be verified     */
/* that they are the same as those entered.                          */

#include <stdio.h>

main ()
  {
   int  i;
   char string [20] = "";           /* initialize input string to null string */
   char *strPtr;


   printf ("Please enter a string which is shorter than 20 characters.\n");
   printf ("Signal string is complete with CR.\n");
   strPtr = gets (string);                /* test reading until CR seen */
   if (strPtr == NULL)
       goto Fail;
   printf ("The string entered was:\n");
   i = puts (string);
   if (i)
       goto Fail1;
   printf ("This message should appear immediately below the string.\n");

   printf ("Please enter only the end-of-file character sequence (CTRL@)\n");
   strPtr = gets (string);               /* test reading with EOF seen before */
   if (strPtr != NULL)                   /*   any other characters            */
       goto Fail2;
   if (! feof (stdin))
       goto Fail3;
   i = fseek (stdin, 0L, SEEK_CUR);                   /* clear EOF indication */
   if (i)
       goto Fail4;

   printf ("The first string entered was:\n");     /* string shouldn't change */
   i = puts (string);
   if (i)
       goto Fail1;
   printf ("\n");

   printf ("Please enter a string which is shorter than 20 characters.\n");
   strPtr = gets (string);                /* test reading until CR seen */
   if (strPtr == NULL)
       goto Fail;
   printf ("The string entered was:\n");
   i = puts (string);
   if (i)
       goto Fail1;
   printf ("This message should appear immediately below the string.\n");

   return 0;

Fail:
   printf ("Failed Special Conformance Test 17.7.0.1\n");
   return 0;

Fail1:
   printf ("Unable to write to standard out\n");
   return 0;

Fail2:
   printf ("Reading EOF before any other chars doesn't return NULL ptr\n");
   return 0;

Fail3:
   printf ("EOF for standard input not detected\n");
   return 0;

Fail4:
   printf ("Unable to FSEEK on stdin\n");
   return 0;
  }
