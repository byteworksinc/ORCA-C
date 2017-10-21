/* Conformance Test 3.3.6.1:  Verify precedence setting with parentheses */
/*                            in macro expansions                        */

#define    SQUARE1(x)  x * x
#define    SQUARE2(x)  (x) * (x)
#define    SQUARE3(x)  ( (x) * (x) )

main ()
  {
   float y;
   int   i;

   y = 3.5;
   y = (int) SQUARE1 (y + 1);
   if (y != 7.5)
       goto Fail;

   y = (int) SQUARE2 (y + 1);
   if (y != 68.0)
       goto Fail;

   i = (int) SQUARE3 (y + 1);
   if (i != 4761)
       goto Fail;

   printf ("Passed Conformance Test 3.3.6.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 3.3.6.1\n");
  }

