/* Conformance Test 3.5.1.4:  Verification of macro expansions in #if */
/*                            commands                                */

#define ONE    1
#define TWO    2
#define THREE  3
#define FOUR   4
#define FIVE   '5'
#define SIX    '6'
#define SEVEN  '7'
#define EIGHT  8
#define NINE   9
#define ZERO   0

#if  ONE * TWO
   #if  SEVEN / ONE
       #if NINE - 8
           #if '\r' + ZERO
               #if (FIVE == '\x35')
                   #if ('\001' != ZERO)
                       #define NUM1 (ONE*TWO) | (SEVEN/ONE) ^ (NINE-8)\
                                    & ('\r'+ZERO)
                   #else
                       #define NUM1 5
                   #endif
               #else
                   #define NUM1 4
               #endif
           #else
               #define NUM1 3
           #endif
       #else
           #define NUM1 2
       #endif
   #else
       #define NUM1 1
   #endif
#else
   #define NUM1 0
#endif

#if (THREE < '7')
   #if ('6' <= SIX)
       #if (EIGHT > 2)
           #if (FOUR >= 4)
               #if (('\n') && ('\003'))
                   #if ((0) || ('d'))
                       #define NUM2 NINE / ONE << THREE >> TWO
                   #else
                       #define NUM2 5
                   #endif
               #else
                   #define NUM2 4
               #endif
           #else
               #define NUM2 3
           #endif
       #else
           #define NUM2 2
       #endif
   #else
       #define NUM2 1
   #endif
#else
   #define NUM2 0
#endif

#if -(3 * SEVEN)
   #if ~(SIX)
       #if !ZERO
           #define NUM3 NUM1 ? NUM2 : 187
       #else
           #define NUM3 2
       #endif
   #else
       #define NUM3 1
   #endif
#else
   #define NUM3 0
#endif

#if (defined(FIVE)) && (defined(SIX)) && (NUM1 == 54) && (NUM2 == 18)\
    && (NUM3 == NUM2)
main ()
  {
   printf ("Passed Conformance Test 3.5.1.4\n");
  }
#else
main ()
  {
printf("%d %d %d\n", NUM1, NUM2, NUM3);
   printf ("Failed Conformance Test 3.5.1.4\n");
  }
#endif
