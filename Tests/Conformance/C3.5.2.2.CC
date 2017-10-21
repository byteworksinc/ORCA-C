/* Conformance Test 3.5.2.2:  Verification of #elif command, using macro */
/*                            substitution                               */

#define MACRO1(x,y,z)      ((x) + (y) * (z))
#define PASS               "Passed Conformance Test 3.5.2.2\n"
#define FAIL               "Failed Conformance Test 3.5.2.2\n"

#if MACRO1 (-6,2,3)
   # define MSG FAIL

#elif MACRO1 (8,-4,2)
   # define MSG FAIL

#elif MACRO1 (16,8,-2)
   # define MSG FAIL

#elif MACRO1 (-10,-5,-2)
   # define MSG FAIL

#elif MACRO1 (2,3,4)
   # define MSG PASS

#elif MACRO1 (1,2,3)
   # define MSG FAIL

#elif MACRO1 (2,3,4)
   # define MSG FAIL

#elif MACRO1 (3,4,5)
   # define MSG FAIL

#elif MACRO1 (4,5,6)
   # define MSG FAIL

#elif MACRO1 (5,6,7)
   # define MSG FAIL

#elif MACRO1 (6,7,8)
   # define MSG FAIL

#elif MACRO1 (7,8,9)
   # define MSG FAIL

#elif MACRO1 (4,2,-2)
   # define MSG FAIL

#elif MACRO1 (0,0,0)
   # define MSG FAIL

#elif MACRO1 (4,5,6)
   # define MSG FAIL

#else
   # define MSG FAIL
#endif

main ()
  {
   printf (MSG);
  }
