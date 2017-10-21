/* Special Conformance Test 4.5.3.1: Verfication of global array declarations */
/*                                                                            */
/* Other files needed: spc4531.exec - Separately compiles, links, and         */
/*                                     executes the files needed to run test  */
/*                     spc4531.1.cc - Extern function which tests the arrays  */
/*                     spc4531.h    - Header file declaring global arrays     */

int  i1 [50], i3 [3] [5] [8];                          /* all basic types */
long L1 [9], L2 [2] [6];

unsigned int  ui3 [4] [5] [1], ui1 [7];
unsigned long ul2 [5] [3], ul1 [1];

comp     c1 [3], c2 [2] [3];
char     ch2 [6] [5], ch1 [10];
float    f1 [3], f4 [2] [3] [1] [4];
double   d2 [2] [4], d1 [8];
extended e1 [9], e2 [7] [3];

                                                       /* conglomerate types */
struct s { int   a;
           float f; };
struct s s1 [10], s2 [5] [4];

enum colors { red, black, green };
enum colors C3 [2] [1] [3], C1 [6];

union longOrShort { int  first;
                    long second; };
union longOrShort u2 [3] [3], u1 [12];

main ()
  {
   extern int TestArray (void);

   if ( TestArray() )
       printf ("Passed Special Conformance Test 4.5.3.1\n");
   else
       printf ("Failed Special Conformance Test 4.5.3.1\n");
  }
