/* Conformance Test 3.5.1.2:  Verification of #if character constant expressions */

#define FIVE '5'
#define SIX  '6'

#if  '2' * '8'
   #if  '4' / '3'
       #if 'A' - 'b'
           #if '\r' + '\f'
               #if ('p' == '\x70')
                   #if ('\001' != 0)
                       #define NUM1 ('2'*'8') | ('4'/'3') ^ ('A'-'b')\
                                    & ('\r'+'\f')
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

#if ('6' < '7')
   #if ('2' <= '2')
       #if ('8' > '7')
           #if ('0' >= '0')
               #if (('\n') && ('\003'))
                   #if ((0) || ('d'))
                       #define NUM2 'z' % '0' << '\01' >> '\x2'
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

#if -('\x7f')
   #if ~('\0')
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

#if (defined(FIVE)) && (defined(SIX)) && (NUM1 == 0xAF8) && (NUM2 == 13)\
    && (NUM3 == NUM2)
main ()
  {
   printf ("Passed Conformance Test 3.5.1.2\n");
  }
#else
main ()
  {
   printf ("Failed Conformance Test 3.5.1.2\n");
  }
#endif
