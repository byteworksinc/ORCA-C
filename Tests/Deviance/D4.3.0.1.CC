/* Deviance Test 4.3.0.1:  Ensure illegal storage class specifications are */
/*                         detected                                        */

typedef double DblFunc (void);

static int ReturnInt (long l); /* ReturnInt should be defined later in file */

auto int s;                    /* auto can only be used in head of block */
register short f;              /* register can only be used with local   */
                               /*   variables and function parameters    */
main ()
  {
   int i;

   extern auto float y;        /* only 1 storage class per declaration */
   auto int register a;
   static typedef int *l;

   i = ReturnInt (55);     /* call static function declared but not defined */
   printf ("Failed Deviance Test 4.3.0.1\n");
  }

/****************************************************************************/

auto double F1 (int a)         /* functions can only be extern or static */
  {
  }

/****************************************************************************/

register int Int (void)        /* functions can only be extern or static */
  {
  }

/****************************************************************************/

DblFunc FF (void)              /* cannot inherit type of function definition */
  {                            /*   from a typedef name                      */
  }

/****************************************************************************/

/* Function parameters can only have storage class register */

static long Long (auto int i, extern float f, static long m, typedef int ptr)
  {
  }
