/* Header file for Special Conformance Test 4.5.3.2 */

extern  int       *i1 [50];                      /* all basic types */
extern  long      *L1 [9];
extern  comp      *c1 [3];
extern  char      *ch1 [10];
extern  float     *f1 [3];
extern  double    *d1 [8];
extern  extended  *e1 [9];

extern  unsigned int  *ui3 [4] [5] [1], *ui1 [7];
extern  unsigned long *ul2 [5] [3], *ul1 [1];

                                                 /* conglomerate types */
struct s { int   a;
           float f; };
extern  struct s *s1 [10], S;

enum colors { red, black, green };
extern  enum colors *en [6], C;

union longOrShort { int  first;
                    long second; };
extern  union longOrShort *u1 [12], U;
