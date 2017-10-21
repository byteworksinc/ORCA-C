/* Deviance Test 2.7.2.1:  Ensure misformed floating-point constants are */
/*                         flagged as errors                             */
main ()
  {
   float   a;
   double  b;

   a = .e+5;               /* no digits before exponent          */
   b = .e-100;

   a = 0x7FE80;            /* hex constant instead of digits     */
   b = 0x33.71;

   a = 0777E5;             /* octal constant instead of digits   */
   b = 0043.71;

   a = 87t4.;              /* invalid character in digit string  */
   b = 2@e-9;

   a = 39e*7;              /* invalid sign character in exponent */
   d = 54E/6;

   a = 98.E 8;             /* space embedded within token        */
   b = 75.4 e+43;

   a = ..45;               /* multiple decimal points            */
   b = 123.6.89;

   printf ("Failed Deviance Test 2.7.2.1\n");
  }
