/* Deviance Test 3.5.1.1:  Check invalid #if, #else commands */

#if                            /* #if with no operand */
#else
#endif

#if a * b
   #define bad "this doesn't evaluate to a constant value"
#else
#endif

#define macro1 1

#if 4                          /* ensure improper nesting is detected */
   #ifdef macro1               /*   in "discarded" lines              */
       #ifndef noName
           #define TEN 10
#elif 5
   #if defined(SIX)
       #ifdef EIGHTYONE

       #endif  /* ifndef noName */
   #endif  /* ifdef macro1 */
#endif  /* if 4 */

#if 1                          /* ...as well as in non-discarded lines */
   #ifdef macro1
       #define SIXTEEN 16
   #endif
/* missing endif */

main ()
  {
   printf ("Failed Deviance Test 3.5.1.1\n");
  }



