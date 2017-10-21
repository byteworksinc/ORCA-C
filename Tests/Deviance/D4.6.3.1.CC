/* Deviance Test 4.6.3.1: Ensure illegal pointer initializations are detected */

main ()
  {
   int i2 [5], i1 = 5;

   static int i1Ptr = i2;              /* can't take address of local array */
   extern int i2Ptr = &i2 [3];

   register float f1 [10];             /* no such thing as register arrays */

   float *fptr = (float) (i1 - 1.0);   /* expression is not integral constant */

   printf ("Failed Deviance Test 4.6.3.1\n");
  }
