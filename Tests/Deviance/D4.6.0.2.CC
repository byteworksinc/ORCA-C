/* Deviance Test 4.6.0.2:  Ensure attempt to initialize variables of type */
/*                         void and function is detected                  */

main ()
  {
   void v3 = 99.0;
   register void v4 = 'a';
   static char F3 (void) = 'm';
   extended F4 (int x, int y) = 4.0E300;

   printf ("Failed Deviance Test 4.6.0.2\n");
  }
