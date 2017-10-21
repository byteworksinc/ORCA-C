/* Conformance Test 3.5.3.1:  Verification of #ifdef and #ifndef commands */

#define ONE    1
#define TWO    2
#define THREE  3
#define FOUR   4

#ifdef ONE
   #define COUNT1  1
#endif

#ifdef TWO
   #define COUNT2  2
#endif

#ifdef THREE
   #define COUNT3  3
#endif

#ifdef FOUR
   #define COUNT4  4
#endif

#undef ONE
#undef TWO
#undef THREE
#undef FOUR

#ifndef ONE
   #define COUNT5  5
#endif

#ifndef TWO
   #define COUNT6  6
#endif

#ifndef THREE
   #define COUNT7  7
#endif

#ifndef FOUR
   #define COUNT8  8
#endif

main ()
  {
   int a;

   a = COUNT1 + COUNT2 + COUNT3 + COUNT4 + COUNT5 + COUNT6 + COUNT7 + COUNT8;
   if (a != 36)
       goto Fail;
   printf ("Passed Conformance Test 3.5.3.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 3.5.3.1\n");
  }
