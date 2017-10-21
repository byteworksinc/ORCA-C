/* Deviance Test 2.7.3.3:  Ensure character constants containing no */
/*                         characters are flagged as errors         */
main ()
  {
   char a, b;

   a = '';
   b = '';

   printf ("Failed Deviance Test 2.7.3.3\n");
  }
