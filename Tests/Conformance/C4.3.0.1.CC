/* Conformance Test 4.3.0.1:  Verification of auto, register, and static */
/*                            storage classes                            */

static long L1 (register int a1, float x1);    /* test forward referencing */
                                               /*   at top level           */

static extended ext = 3.678;                   /* ensure static variables */
static int j = 2;                              /*   initialized correctly */
static int i;                                  /* should automatically be */
                                               /*   set to zero           */

main ()
  {
   static void V1 (void);              /* test forward referencing within */
                                       /*   function                      */
   long LL = 3;

   if (ext != 3.678)
       goto Fail;

     {
       auto i = 10;                    /* this i hides top-level i        */
       for (; i < 15; i++)
         {
           V1 ();
           switch (i)
             {
               case 10:    if (j != 3)
                               goto Fail;
                           break;

               case 11:    if (j != 4)
                               goto Fail;
                           break;

               case 12:    if (j != 5)
                               goto Fail;
                           break;

               case 13:    if (j != 6)
                               goto Fail;
                           break;

               case 14:    if (j != 7)
                               goto Fail;
                           break;

               default:    goto Fail;
                           break;

             }  /* end switch */
         }  /* end for */
     }  /* end inner block */

   if (i != 5)                         /* top-level i */
       goto Fail;

   for (i = 0; i < 7; i++)             /* L0 should be init. to 10 with each */
     {                                 /*   pass through the for loop; F0    */
       auto   int   L0 = 10;           /*   should be initialized once       */
       static float F0 = 1.0;

       LL = L1 (L0, F0);
       if (LL)
           goto Fail;
       F0 += 1.0;
       if (F0 == 3.0)
           break;
     }
   if (i != 1)                         /* test that F0 was not reset */
       goto Fail;

   printf ("Passed Conformance Test 4.3.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.3.0.1\n");
  }

/******************************************************************************/

static long L1 (register int a1, float x1)     /* ensure classification as  */
  {                                            /*   register doesn't affect */
                                               /*   value of parameter      */
   if (a1 != 10)                       /* a1 should be 10 each time called  */
       return 1;
   else
       return 0;
  }

/******************************************************************************/

static void V1 (void)
  {
   ++i; j++;                                   /* ensure i, j are visible */
  }
