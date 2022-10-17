/* Deviance Test 3.3.5.1:  Check error generation for #undef commands */

int printf(const char *, ...);

#undef Name    #define Name    "hey"   /* macro replacement is NOT done */
                                       /*   for #undef commands         */

#define    A   "5"
#define    A   "you"
#undef     A                       /* check "stack model" of redefining*/
                                   /*   macros -- not ANSI C           */
#define    cantUseIt   10
#undef     cantUseIt

int main (void)
  {
   char a[] = A;
   int  i;

   i = cantUseIt;
   printf ("Failed Deviance Test 3.3.5.1\n");
  }
