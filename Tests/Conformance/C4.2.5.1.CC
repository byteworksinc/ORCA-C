/* Conformance Test 4.2.5.1:  Verification of duplicate extern references */

int   a;
extern float F1 (int x, int y);

main ()
  {
   extern   int   a;
   extern   float F1 (int x, int y);
   float    x;
   extern   extended G1 (void);

   a = (int) F1 (2, 3);
   if (a != 5)
       goto Fail;

   x = (float) G1 ();
   if (x != 10.0)
       goto Fail;

   printf ("Passed Conformance Test 4.2.5.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.2.5.1\n");
  }

/*****************************************************************************/

extended G1 (void)
  {
   extern float F1 (int x, int y);
   extern int a;

   return (F1 (a, 5));
  }

/*****************************************************************************/

float F1 (int x, int y)
  {
   extern extended G1 (void);
   extern int      a;

   return (float) (x + y);
  }
