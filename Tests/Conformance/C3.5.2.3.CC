/* Conformance Test 3.5.2.3:  Verification of nested #elif commands */

#define PASS  "Passed Conformance Test 3.5.2.3\n"
#define FAIL  "Failed Conformance Test 3.5.2.3\n"

main ()
  {
   #if 1
       #if 2
           #if 0
               printf (FAIL);
           #elif 0
               printf (FAIL);
           #elif 32767
               printf (PASS);
           #endif
       #elif 3
           printf (FAIL);
       #elif 0
           printf (FAIL);
       #else
           printf (FAIL);
       #endif
   #elif 5
       printf (FAIL);
   #elif 6
       printf (FAIL);
   #elif 7
       printf (FAIL);
   #elif 8
       printf (FAIL);
   #elif 0
       printf (FAIL);
   #else
       printf (FAIL);
   #endif
  }
