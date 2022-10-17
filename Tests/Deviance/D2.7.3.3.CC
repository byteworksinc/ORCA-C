/* Deviance Test 2.7.3.3:  Ensure character constants containing no */
/*                         characters are flagged as errors         */

int printf(const char *, ...);

int main (void)
  {
   char a, b;

   a = '';
   b = '';

   printf ("Failed Deviance Test 2.7.3.3\n");
  }
