/* Conformance Test 3.3.3.1:  Ensure correct macro expansion for nested */
/*                            macros and nested macro calls             */

#define    addMult(a,b,c)  mult ( (add((a),(c))), (b) )
#define    mult(x,y)       (y) * (x)
#define    add(i,j)        (i) + (j)

main ()
  {
   long i, j, k, m;

   i = 2;
   j = 3;
   k = 5;

   m = addMult (i, j, k);
   if (m != 21)
       goto Fail;

   m = addMult ( (mult (j,k)), (add (m,i)), 4 );
   if (m != 437)
       goto Fail;

   j = add ( (mult (k,i)), (addMult ((m), (mult ((i), (add (m,m))) ), (k))));
   if (j != 772626)
       goto Fail;

   printf ("Passed Conformance Test 3.3.3.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 3.3.3.1\n");
  }
