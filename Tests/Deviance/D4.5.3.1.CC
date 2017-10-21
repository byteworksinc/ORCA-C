/* Deviance Test 4.5.3.0.1:  Ensure illegal array dimensions are detected */

static  int x [0];                     /* zero not allowed for dimension */
static  float y [0] [5] [9];
static  double k [3] [6] [2] [0];

static  extended L [-3] [7];           /* negative dimension not allowed   */
static  long M [8] [2] [];             /* must specify LAST n-1 dimensions */

/*****************************************************************************/

int F1 (float n [3] [])
  {
   return 0;
  }


/*****************************************************************************/

long L1 (char ch1 [] [])
  {
   return 0;
  }

/*****************************************************************************/


main ()
  {
   char ch0 [0], ch2 [9] [0], ch3 [8] [7] [0] [6];
   extended ext [2] [0] [9] [0];
   int i [3] [] = { 1, 2 };            /* must specify LAST n-1 dimensions */
   int k;
   float n [5] [3];

   k = F1 (n [5] []);
   k = F1 (n);

   printf ("Failed Deviance Test 4.5.3.0.1\n");
  }
