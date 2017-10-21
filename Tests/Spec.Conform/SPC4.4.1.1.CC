/* Special Conformance Test 4.4.1.1:  Verification of ability to omit either */
/*                                    type specifier or storage class in     */
/*                                    declarations, and both in function     */
/*                                    definitions                            */
/*                                                                           */
/* Other files needed: spc4411.exec - separately compiles, links, and        */
/*                                    executes the files spc4.4.1.1.cc and   */
/*                                    spc4411.1.cc                           */
/*                                                                           */

static x;                                    /* type of x is int             */
float y;                                     /* storage class of y is extern */

static F1 ();                          /* non-prototyped form:  returns int  */
double G1 ();                          /* also non-prototyped form:  storage */
                                       /*   class is extern                  */

main ()
  {
   x = 0x7f << 2;                      /* if type is not int, error would be */
   if (x != 0x1FC)                     /*   flagged                          */
       goto Fail1;

   y = 8.7;
   y = G1 (x);
   if (y != 508.0)
       goto Fail2;

   x = F1 (3, 4);
   if (x != 7)
       goto Fail;

   printf ("Passed Special Conformance Test 4.4.1.1\n");
   return;

Fail:
   printf ("Failed Special Conformance Test 4.4.1.1\n");
   return;

Fail1:
   printf ("extern int x not set correctly: x = %d\n", x);
   goto Fail;

Fail2:
   printf ("extern double function G1 returns incorrect value: y = %f\n", y);
   goto Fail;

Fail3:
   printf ("static int function F1 returns incorrect value: x = %d\n", x);
   goto Fail;
  }

/******************************************************************************/

F1 (x, y)
  int x;
  int y;
  {
   return x + y;
  }
