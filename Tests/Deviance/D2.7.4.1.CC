/* Deviance Test 2.7.4.1:  Ensure string constants with no closing " are */
/*                         flagged as errors                             */

int printf(const char *, ...);

int main (void)
  {
   char string [] = "badly formed string ;

   strcpy (string, "another bad string );

   printf ("Failed Deviance Test 2.7.4.1\n");
  }
