/* Conformance Test 3.5.4.2:  Verification of #elif character constant */
/*                            expressions                              */

#define FIVE '5'
#define SIX  '6'

#if 0
   #define NUM1 0
#elif  '2' * '8'
   #define NUM1 '2' * '8'
#else
   #define NUM1 0
#endif

#if 0
   #define NUM2 0
#elif  '4' / '3'
   #define NUM2 '4' / '3'
#else
   #define NUM2 0
#endif

#if 0
   #define NUM3 0
#elif 'b' - 'a'
   #define NUM3 'b' - 'a'
#else
   #define NUM3 0
#endif

#if 0
   #define NUM4 0
#elif '\r' + '\f'
   #define NUM4 '\r' + '\f'
#else
   #define NUM4 0
#endif

#if 0
   #define NUM5 0
#elif ('p' == '\x70')
   #define NUM5 (('\p') == '\x70')
#else
   #define NUM5 0
#endif

#if 0
   #define NUM6 0
#elif ('\001' != 0)
   #define NUM6 ('2'*'8') | ('4'/'3') ^ ('A'-'b')\
                                    & ('\r'+'\f')
#else
   #define NUM6 0
#endif

#if 0
   #define NUM7 0
#elif ('6' < '7')
   #define NUM7 '6' < '7'
#else
   #define NUM7 0
#endif

#if 0
   #define NUM8 0
#elif ('2' <= '2')
   #define NUM8 '2' <= '2'
#else
   #define NUM8 0
#endif

#if 0
   #define NUM9 0
#elif ('8' > '7')
   #define NUM9 '8' > '7'
#else
   #define NUM9 0
#endif

#if 0
   #define NUM10 0
#elif ('0' >= '0')
   #define NUM10 '0' >= '0'
#else
   #define NUM10 0
#endif

#if 0
   #define NUM11 0
#elif (('\n') && ('\003'))
   #define NUM11 (('\n') && ('\003'))
#else
   #define NUM11 0
#endif

#if 0
   #define NUM12 0
#elif ((0) || ('d'))
   #define NUM12 'z' % '0' << '\01' >> '\x2'
#else
   #define NUM12 0
#endif

#if 0
   #define NUM13 0
#elif -('\x7f')
   #define NUM13  (-('\x7f'))
#else
   #define NUM13 0
#endif

#if 0
   #define NUM14 0
#elif ~('\0')
   #define NUM14 ~'\0'
#else
   #define NUM14 0
#endif

#if 0
   #define NUM15 0
#elif !0
   #define NUM15 NUM1 ? NUM2 : 187
#else
   #define NUM15 0
#endif

#if 0
#elif (defined(FIVE)) && (defined(SIX)) && (NUM1 == 0xAF0) && (NUM2 == 1)\
       && (NUM3 == NUM2)
main ()
  {
   if (NUM1    != 2800  )  goto Fail;
   if (NUM2    != 1     )  goto Fail;
   if (NUM3    != 1     )  goto Fail;
   if (NUM4    != 25    )  goto Fail;
   if (NUM5    != 1     )  goto Fail;
   if ((NUM6)  != 0xAF8 )  goto Fail;
   if (NUM7    != 1     )  goto Fail;
   if (NUM8    != 1     )  goto Fail;
   if (NUM9    != 1     )  goto Fail;
   if (NUM10   != 1     )  goto Fail;
   if (NUM11   != 1     )  goto Fail;
   if (NUM12   != 13    )  goto Fail;
   if (NUM13   != -127  )  goto Fail;
   if (NUM14   != -1    )  goto Fail;
   if ((NUM15) != 1     )  goto Fail;

   printf ("Passed Conformance Test 3.5.4.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 3.5.4.2; location 1\n");
  }

#else
main ()
  {
   printf ("Failed Conformance Test 3.5.4.2; location 2\n");
  }
#endif
