/* Conformance Test 3.5.1.3:  Verify macro expansion in #if commands */

#define VAL1 1
#undef  VAL1

#if !VAL1              /* VAL1 should be undefined, and so evaluate as 0 */
main ()
  {
   printf ("Passed Conformance Test 3.5.1.3\n");
  }
#else
main ()
  {
   printf ("Failed Conformance Test 3.5.1.3\n");
  }
#endif
