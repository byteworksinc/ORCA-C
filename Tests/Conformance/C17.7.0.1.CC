/* Conformance Test 17.7.0.1:  Verification of fgets function, text stream */

#include <stdio.h>

main ()
  {
   FILE *f1;
   int  i;
   char string [80] = "";           /* initialize input string to null string */
   char *strPtr;


   f1 = fopen ("3/tmp", "w+");                 /* create text file to work on */
   if (f1 == NULL)
       goto Fail1;
   i = fputs ("Every good boy deserves favor\n", f1);
   if (i)
       goto Fail2;

   rewind (f1);                            /* test reading until '\n' seen */
   strPtr = fgets (string, 100, f1);
   if (strPtr == NULL)
       goto Fail;
   if (strcmp ("Every good boy deserves favor\n", string))
       goto Fail;

   fgetc(f1);                            /* force an EOF condition */
   strPtr = fgets (string, 100, f1);     /* test reading with EOF seen before */
   if (strPtr != NULL)                   /*   any other characters            */
       goto Fail;
   if (! (feof (f1)) )
       goto Fail;
   if (strcmp ("Every good boy deserves favor\n", string))
       goto Fail;

   rewind (f1);                          /* test reading until n-1 chars seen */
   strPtr = fgets (string, 15, f1);
   if (strPtr == NULL)
       goto Fail;
   if (strcmp ("Every good boy", string))
       goto Fail;

   strPtr = fgets (string, 17, f1);      /* ensure fgets moves internal file */
   if (strPtr == NULL)                   /*   pointer                        */
       goto Fail;
   if (strcmp (" deserves favor\n", string))
       goto Fail;

   fgetc(f1);                            /* force an EOF condition */
   strPtr = fgets (string, 100, f1);     /* test reading with EOF seen before */
   if (strPtr != NULL)                   /*   any other characters            */
       goto Fail;
   if (! (feof (f1)) )
       goto Fail;
   if (strcmp (" deserves favor\n", string))
       goto Fail;

   i = fclose (f1);                    /* close file and quit */
   if (i)
       goto Fail3;

   printf ("Passed Conformance Test 17.7.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.7.0.1\n");
   return;

Fail1:
   printf ("Unable to open temp file for Conformance Test 17.7.0.1\n");
   return;

Fail2:
   printf ("Unable to write to temp file for Conformance Test 17.7.0.1\n");
   return;

Fail3:
   printf ("Unable to close temp file for Conformance Test 17.7.0.1\n");
   return;
  }
