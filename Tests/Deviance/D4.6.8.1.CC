/* Deviance Test 4.6.8.1:  Ensure improper dropping of initializer braces */
/*                         is detected                                    */

static int i1 [3] = 1, 2, 3;       /* can't drop outer braces for arrays */
float f1 [2] = 3.1, 2.3;           /*   and structures                   */

struct S1 { char ch; float f; };
static struct S1 s1 = 'a', 3.3;
struct S1 s2 = 'b', 4.4;

struct S2 { comp c1 [3]; long L1 [2]; char ch; };

main ()
  {
   unsigned int ui1 [4] = 2, 3;    /* can't drop outer braces for arrays */
   struct S1 s3 = 'a', 3.3;        /*   and structures                   */

   printf ("Failed Deviance Test 4.6.8.1\n");
  }
