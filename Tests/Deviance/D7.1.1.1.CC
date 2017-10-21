/* Deviance Test 7.1.1.1:  Ensure illegal use of non-lvalues is detected */

main ()
  {
   int i [10];                         /* names of arrays, functions, enum */
   enum E {a, b, c};                   /*   constants, & void variables    */
   void v;                             /*   are not lvalues                */
   static float F (void);
   float (*fptr) ();

   i = 5;                              /* cannot apply &, ++, --, or assign */
   a++;                                /*   operators to non-lvalues        */
   v = F ();
   fptr = &(F--);
   --i;
   ++b;
   --c;

   printf ("Failed Deviance Test 7.1.1.1\n");
  }

static float F (void)
  {
   return 1.0;
  }
