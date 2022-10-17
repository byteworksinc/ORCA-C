/* Conformance Test 3.3.9.1:  Verification of token merging in macro */
/*                            expansions                             */

int printf(const char *, ...);

#define    INCR(j,k)   j##k

int main (void)
  {
   int  x, y;

   x = 3;
   y = INCR (+, +) x;
   if (x != 4 || y != 4)
       goto Fail;

   printf ("Passed Conformance Test 3.3.9.1\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 3.3.9.1\n");
  }
