/* Deviance Test 2.2.0.2:  Ensure comments without terminators are flagged */
/*                         as errors                                       */

int printf(const char *, ...);

int main (void)
  {
   /* don't terminate this one

   int a;

   */   and then try to comment here */

   a = 3;
   printf ("Failed Deviance Test 2.2.0.2\n");
  }
