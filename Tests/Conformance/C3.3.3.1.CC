/* Conformance Test 3.3.3.1:  Prefix increment/decrement and nested      */
/*                            macro expansion                            */

#pragma debug 32

int printf(const char *, ...);

#define    addMult(a,b,c)  mult ( (add((a),(c))), (b) )
#define    mult(x,y)       (y) * (x)
#define    add(i,j)        (i) + (j)

char buf[8] = "abcdefg";

int main (void)
  {
   long i, j, k, m;
    long n;
    char *p;
    char c;

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

   p = buf;
   n = 0;
   c = *++p;
   if ((c != 'b') || (p != buf + 1))
       goto Fail;

   n = 0;
   *--p = 'a';
   if ((buf[0] != 'a') || (p != buf))
       goto Fail;

   printf ("Passed Conformance Test 3.3.3.1\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 3.3.3.1\n");
  }
