/* External array declarations needed to run Special Conformance Test 4.5.3.1 */

extern int  i1 [50], i3 [3] [5] [8];                   /* all basic types */
extern long L1 [9], L2 [2] [6];

extern unsigned int  ui3 [4] [5] [1], ui1 [7];
extern unsigned long ul2 [5] [3], ul1 [1];

extern comp     c1 [3], c2 [2] [3];
extern char     ch2 [6] [5], ch1 [10];
extern float    f1 [3], f4 [2] [3] [1] [4];
extern double   d2 [2] [4], d1 [8];
extern extended e1 [9], e2 [7] [3];

                                                       /* conglomerate types */
struct s { int   a;
           float f; };
extern struct s s1 [10], s2 [5] [4];

enum colors { red, black, green };
extern enum colors C3 [2] [1] [3], C1 [6];

union longOrShort { int  first;
                    long second; };
extern union longOrShort u2 [3] [3], u1 [12];
