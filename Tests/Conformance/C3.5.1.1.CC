/* Conformance Test 3.5.1.1:  Verification of #if constant expressions */

#define FIVE 5
#define SIX  6

#if  2 * 8
   #if  4 / 3
       #if 209 - 8
           #if 32760 + 7
               #if (5 == 5)
                   #if (2 != 0)
                       #define NUM1 (2*8) | (4/3) ^ (209-208) & (32760+7)
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

#if (6 < 32767)
   #if (20004 <= 20004)
       #if (59876 > 59875)
           #if (671234 >= 671234)
               #if ((2) && (3))
                   #if ((0) || (1))
                       #define NUM2 2147 % 3 << 3 >> 2
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

#if (-32768)
   #if ~0x7e
       #if !0
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

#if (defined(FIVE)) && (defined(SIX)) && (NUM1 == 0x10) && (NUM2 == 4)\
    && (NUM3 == NUM2)
main ()
  {
   printf ("Passed Conformance Test 3.5.1.1\n");
  }
#else
main ()
  {
   printf ("Failed Conformance Test 3.5.1.1\n");
  }
#endif
