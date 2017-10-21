/* Conformance Test 3.3.2.1:  Verification of macros with parameters */

#define subtract(x,y)  x - y
#define noParmsPass()  printf ("Passed Conformance Test 3.3.2.1\n");
#define noParmsFail()  printf ("Failed Conformance Test 3.3.2.1\n");
#define many_parms(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) \
a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t+u+v+w+x+y+z
#define real           float

main ()
  {
   double f1(), g1();
   int  i;
   long j;
   real x, y;

   i = subtract (3, 5);
   if (i != -2)
       goto Fail;

   x = 3.5e4;
   y = 2.8e0;
   j = subtract (((long) f1(x)), ((int) g1(y)));
   if (j != 69995)
       goto Fail;

   i = many_parms (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
                   17, 18, 19, 20, 21, 22, 23, 24, 25, 26);
   if (i != 351)
       goto Fail;

   noParmsPass ()
   return;

Fail:
   noParmsFail ()
  }

/**************************************************************************/
double f1 ( y )
   real y;
  {
   return (y * 2.0);
  }

/**************************************************************************/
double g1 ( x )
   real x;
  {
   return (x / 0.5e+0);
  }
