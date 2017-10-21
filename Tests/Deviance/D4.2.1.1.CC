/* Deviance Test 4.2.1.1:  Ensure invalid scoping of identifiers is detected */

main ()
  {
   int     i;

   struct  ComplexNum  c;
   struct  ComplexNum  { float real;
                         float imag; };
   struct  ComplexNum  d;

   union   LongOrShort z;
   union   LongOrShort { long longNum;
                         int  shortNum; };
   union   LongOrShort ls;

   enum    flowers f;
   enum    flowers { rose, iris, canation };
   enum    flowers g;

   intPtr  k;                          /* types not defined yet */
   typedef int *intPtr;

   d.noSuchField = 0.0;
   z.real        = 5;
   g             = dahlia;
   ls.noNumber   = 10;
   goto Hell;                                      /* no offense... */
   ch = F1 (g, i);
   G1();

   printf ("Failed Conformance Test 4.2.1.1\n");
  }

/****************************************************************************/

char F1 (int x, int y);
  {
   intPtr k;
   struct ComplexNum  c, *d;
   union  LongOrShort z;
   enum   flowers     f;

   i = 5;
   G1();
   return (3);
  }

/******************************************************************************/

void G1 (void);
  {
   x += y;
   return;
  }
