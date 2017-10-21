/* Deviance Test 3.3.5.1:  Check error generation for #undef commands */

#undef Name    #define Name    "hey"   /* macro replacement is NOT done */
                                       /*   for #undef commands         */

#define    A   "5"
#define    A   "you"
#undef     A                       /* check "stack model" of redefining*/
                                   /*   macros -- not ANSI C           */
#define    cantUseIt   10
#undef     cantUseIt

main ()
  {
   char a[] = A;
   int  i;

   i = cantUseIt;
   printf ("Failed Deviance Test 3.3.5.1\n");
  }
