/* Deviance Test 3.5.2.1: Ensure illegal #elif commands are flagged as errors */

#if 0
   #define WHO_CARES 0
#elif 0
   #if 1
       #define WHO_REALLY_CARES 1
   #elif 2
       #define ARE_YOU_KIDDING  2
   #elif 3
       #define WHATS_FOR_LUNCH  3
   #else
       #define LETS_LEAVE_OFF   "endif"

#elif 1
   #define CATS_R_US 'c'
   #if CATS_R_US
       #define DOGS_R_US 'd'
   #endif

#else
   #define LETS_NOT_LEAVE_OFF  "endif"

#endif

#if 0
#elif      /* no expression */
#endif

main ()
  {
   printf ("Failed Deviance Test 3.5.2.1\n");
  }
