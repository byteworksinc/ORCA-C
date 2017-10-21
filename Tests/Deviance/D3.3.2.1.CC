/* Deviance Test 3.3.2.1:  Ensure invalid macro definitions/invocations */
/*                         are flagged as errors                        */

#define sameName1(name1,name1)         name1 * name1
#define missingRParen(x,y              x / y
#define sameName1(a,b)                 a | b
#define argsSeparatedWithSpaces(e f)   e - f
#define badArgs(&y,->t)                &y & ->t
#define sameName2                      88 - 9
#define oneGoodOne(z1,z2)              z1 * z2
#define sameName2                      " same name 2 "

main ()
  {
   int a, b, c;

   /* Invoke macro with too few parameters. */
   a = 3;
   c = oneGoodOne (a);

   /* Invoke macro with too many parameters. */
   a = oneGoodOne (a, b, c);

   printf ("Failed Deviance Test 3.3.2.1\n");
  }
