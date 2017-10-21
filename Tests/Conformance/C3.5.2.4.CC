/* Conformance Test 3.5.2.4:  Verification of nested #elif commands, using */
/*                            macro substitution                           */

#define PASS  "Passed Conformance Test 3.5.2.4\n"
#define FAIL  "Failed Conformance Test 3.5.2.4\n"

#define CALL1(a,b,c)   ((a) - (b) * (c))
#define CALL2(x,y)     ((x) || (y))

main ()
  {
   #if CALL1 (6,2,3)
       #if CALL1 (8,2,4)
           #if CALL2 (0,0)
               printf (FAIL);
           #elif 0
               printf (FAIL);
           #elif 32767
               printf (FAIL);
           #endif
       #elif CALL1 (10,3,4)
           printf (FAIL);
       #elif CALL2 (7,0)
           printf (FAIL);
       #else
           printf (FAIL);
       #endif
   #elif CALL1 (12,4,3)
       printf (FAIL);
   #elif CALL2 ((5-(4+1)), 0)
       printf (FAIL);
   #elif CALL1 (16,4,4)
       printf (FAIL);
   #elif 0
       printf (FAIL);
   #elif CALL1 (20,-10,-2)
       printf (FAIL);
   #else
       printf (PASS);
   #endif
  }
