/* Conformance Test 4.4.2.1:  Ensure compile accepts missing declarators   */

struct {int   a;                       /* can't use it, but it's legal     */
        float x;};

int ;                                  /* nothing declared, but it's legal */

static enum E {a, b, c};               /* storage class ignored            */

main ()
  {
   struct {double d;
           short  s;};
   extended;
   extern union U {int  i;
                   long l;};

   printf ("Passed Conformance Test 4.4.2.1\n");
  }
