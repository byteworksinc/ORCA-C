/* Special Conformance Test 4.5.3.2: Verfication of external array       */
/*                                   declarations: arrays of pointers    */
/*                                                                       */
/* Other files needed: spc4532.1.cc - separately compiled file           */
/*                                    containing test of arrays          */
/*                     spc4532.h    - header file containing extern      */
/*                                    declarations needed by second file */
/*                     spc4532.exec - EXEC file which separately compiles*/
/*                                    links and executes test 4.5.3.0.2  */

int       *i1 [50];                               /* all basic types */
long      *L1 [9];
comp      *c1 [3];
char      *ch1 [10];
float     *f1 [3];
double    *d1 [8];
extended  *e1 [9];

unsigned int  *ui3 [4] [5] [1], *ui1 [7];
unsigned long *ul2 [5] [3], *ul1 [1];

                                                 /* conglomerate types */
struct s { int   a;
           float f; };
struct s *s1 [10], S;

enum colors { red, black, green };
enum colors *en [6], C;

union longOrShort { int  first;
                    long second; };
union longOrShort *u1 [12], U;


main ()
  {
   extern int TestEm (void);

   if (TestEm)
       printf ("Passed Special Conformance Test 4.5.3.2\n");
   else
       printf ("Failed Special Conformance Test 4.5.3.2\n");
  }
