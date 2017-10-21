/* Conformance Test 3.3.0.1:  Ensure macro names are ignored in comments */
/*                            and string constants                       */
#define sum(x,y)  x+y
#define mult(x,y) x*y

main ()
  {
   char  a[25];
   int   x, y;

   x = /* sum(4,7) */ 10;              /* This should be ignored      */
   y = /* mult(3,5)   */ 2 * 9;        /* This should also be ignored */

   if ((x != 10) || (y != 18))
       goto Fail;

   strcpy (a, "sum(x,y) mult(a,b)");   /* should also be ignored */
   if ((strcmp (a, "sum(x,y) mult(a,b)")) != 0)
       goto Fail;

   printf ("Passed Conformance Test 3.3.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 3.3.0.1\n");
  }


