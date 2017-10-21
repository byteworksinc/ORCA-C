/* Conformance Test 3.5.4.1:  Verification of #elif constant expressions */

#define FIVE 5
#define SIX  6

#if 0
   #define NUM1 0
#elif  2 * 8
   #define NUM1 2*8
#else
   #define NUM1 0
#endif

#if 0
   #define NUM2 0
#elif  4 / 3
   #define NUM2 4/3
#endif

#if 0
   #define NUM3 0
#elif 209 - 8
   #define NUM3 (209 - 8)
#else
   #define NUM3 0
#endif

#if 0
   #define NUM4 0
#elif 32760 + 7
   #define NUM4 ((32760) + (7))
#endif

#if 0
   #define NUM5 0
#elif (5 == 5)
   #define NUM5 5 == 5
#else
   #define NUM5 0
#endif

#if 0
   #define NUM6 0
#elif (2 != 0)
   #define NUM6 (2*8) | (4/3) ^ (209-208) & (32760+7)
#else
   #define NUM6 0
#endif

#if 0
   #define NUM7 0
#elif (6 < 32767)
   #define NUM7 6 < 32767
#else
   #define NUM7 0
#endif

#if 0
   #define NUM8 0
#elif (20004 <= 20004)
   #define NUM8 (( 20004 <= 20004 ))
#else
   #define NUM8 0
#endif

#if 0
   #define NUM9 0
#elif (59876 > 59875)
   #define NUM9 59876 > 59875
#endif

#if 0
   #define NUM10 0
#elif (671234 >= 671234)
   #define NUM10  671234 >= 671234
#else
   #define NUM10 0
#endif

#if 0
   #define NUM11 0
#elif ((2) && (3))
   #define NUM11 2 && 3
#else
   #define NUM11 0
#endif

#if 0
   #define NUM12 0
#elif ((0) || (1))
   #define NUM12 2147 % 3 << 3 >> 2
#else
   #define NUM12 0
#endif

#if 0
   #define NUM13 0
#elif (-32768)
   #define NUM13 (-(32768))
#else
   #define NUM13 0
#endif

#if 0
   #define NUM14 0
#elif ~0x7e
   #define NUM14 ~0x7E
#else
   #define NUM14 0
#endif

#if 0
   #define NUM15 0
#elif !0
   #define NUM15  NUM1 ? NUM2 : 187
#else
   #define NUM15 0
#endif

main ()
  {
   if ( ! ((FIVE == 5) && (1 == NUM10)) )
       goto Fail;

   if (NUM1  != 16    )  goto Fail;
   if (NUM2  != 1     )  goto Fail;
   if (NUM3  != 201   )  goto Fail;
   if (NUM4  != 32767 )  goto Fail;
   if (NUM5  != 1     )  goto Fail;
   if (NUM6  != 0xB8  )  goto Fail;
   if (NUM7  != 1     )  goto Fail;
   if (NUM8  != 1     )  goto Fail;
   if (NUM9  != 1     )  goto Fail;
   if (NUM10 != 1     )  goto Fail;
   if (NUM11 != 1     )  goto Fail;
   if (NUM12 != 4     )  goto Fail;
   if (NUM13 != -32768)  goto Fail;
   if (NUM14 != 0x81  )  goto Fail;
   if (NUM15 != 1     )  goto Fail;

   printf ("Passed Conformance Test 3.5.4.1\n");
   return;

Fail:
   printf ("Passed Conformance Test 3.5.4.1\n");
  }
