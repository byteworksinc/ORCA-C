/* Conformance Test 3.5.1.5:  Ensure #if, #else with no lines to compile */
/*                            are not errors                             */

#if 5
#else
#endif

#if !0
   #define TRUE 1
#else
#endif

#if 32767
#else
   #define FALSE 0
#endif

#if defined(FALSE)
   #define fail 1
#else
   #define fail 0
#endif

main ()
  {
   if (TRUE != 1)
       goto Fail;

   if (fail)
       goto Fail;

   printf ("Passed Conformance Test 3.5.1.5\n");
   return;

Fail:
   printf ("Failed Conformance Test 3.5.1.5\n");
  }


