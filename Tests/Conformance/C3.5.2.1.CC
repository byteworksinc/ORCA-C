/* Conformance Test 3.5.2.1:  Verification of #elif command */

#if 0
   # define MSG "Failed Conformance Test 3.5.2.1; location 1\n"

#elif (5 - 5)
   # define MSG "Failed Conformance Test 3.5.2.1; location 2\n"

#elif 1
   # define MSG "Passed Conformance Test 3.5.2.1\n"

#elif 2
   # define MSG "Failed Conformance Test 3.5.2.1; location 3\n"

#elif 3
   # define MSG "Failed Conformance Test 3.5.2.1; location 4\n"

#elif 4
   # define MSG "Failed Conformance Test 3.5.2.1; location 5\n"

#elif 5
   # define MSG "Failed Conformance Test 3.5.2.1; location 6\n"

#elif 6
   # define MSG "Failed Conformance Test 3.5.2.1; location 7\n"

#elif 7
   # define MSG "Failed Conformance Test 3.5.2.1; location 8\n"

#else
   # define MSG "Failed Conformance Test 3.5.2.1; location 9\n"
#endif

main ()
  {
   printf (MSG);
  }
