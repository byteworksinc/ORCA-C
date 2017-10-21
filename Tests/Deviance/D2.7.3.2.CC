/* Deviance Test 2.7.3.2:  Ensure character constants contain only 1 charactr */

/* PAGE 20:  DRAFT ANSI C PERMITS MULTIPLE CHAR CONSTANTS -- VALUE IS  */
/*           IMPLEMENTATION DEFINED                                    */

main ()
  {
   char a;

   a = 'ab';
   a = '\t\n';
   a = '\006HELP';

   printf ("Failed Deviance Test 2.7.3.2\n");
  }
