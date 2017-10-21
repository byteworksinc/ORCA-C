/* Deviance Test 4.6.0.1:  Ensure attempt to initialize variables of type */
/*                         void and function is detected                  */

static void v1 = 5;
void v2 = 88;

static int F1 (char ch) = 5;
float F2 (double d3) = 5.6;

main ()
  {
   printf ("Failed Deviance Test 4.6.0.1\n");
  }
