/* Deviance Test 2.7.3.1:  Ensure unterminated character constants are */
/*                         flagged as errors                           */
main ()
  {
   char a;
   int  j;

   a = 'a;
   j = 5 * 76;
   a = '\t;
   a = '\006;

   printf ("Failed Deviance Test 2.7.3.1\n");
  }
