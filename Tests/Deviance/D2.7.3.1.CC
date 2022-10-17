/* Deviance Test 2.7.3.1:  Ensure unterminated character constants are */
/*                         flagged as errors                           */

int printf(const char *, ...);

int main (void)
  {
   char a;
   int  j;

   a = 'a;
   j = 5 * 76;
   a = '\t;
   a = '\006;

   printf ("Failed Deviance Test 2.7.3.1\n");
  }
