/* Conformance Test 4.4.2.1:  Ensure compile accepts missing declarators   */

extern struct S;                       /* forward-declared struct type,    */
                                       /* storage class ignored            */

struct S {int   a;
          float x;};

struct S;

static enum E {a, b, c};               /* storage class ignored            */
extern enum {x, y, z};

main ()
  {
   struct S;                           /* different from the global one    */
   volatile const register struct T;
   extern union U {int  i;
                   long l;};

   printf ("Passed Conformance Test 4.4.2.1\n");
  }
