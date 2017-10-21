/* Conformance Test 3.3.9.1:  Verification of token merging in macro */
/*                            expansions                             */

#define    INCR(j,k)   j##k

main ()
  {
   int  x;

   x = 3;
   x = INCR (+, +) x;
   if (x != 4)
       goto Fail;

   printf ("Passed Conformance Test 3.3.9.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 3.3.9.1\n");
  }
