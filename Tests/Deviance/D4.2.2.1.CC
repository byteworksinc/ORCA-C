/* Deviance Test 4.2.2.1:  Ensure "hiding" identifiers with same scope is */
/*                         detected                                       */

#define MAC1 1                         /* macro name        */
#define MAC1 8

typedef int   *intPtr;                 /* user-defined type */
typedef float *intPtr;

int    a;                              /* variables         */
double a;

struct aRecord { int a; };             /* type tag names    */
union  aRecord { long one;
                 int  two; };
enum   aRecord { rec1, rec2, rec3 };

struct repeats { int   r1;             /* component names   */
                 char  ch;
                 float r1; };

union  moreRepeats { float  x;
                     int    y;
                     double y; };

enum   stillOthers { red, black, green, green };

double D2 (int x, int z);              /* function names    */
int    D2 (char k);

main ()
  {
   #define MAC2 2                         /* macro name        */
   #define MAC2 3

   typedef char  *chPtr;                  /* user-defined type */
   typedef short *chPtr;

   int    cantRedeclare;                  /* variables         */
   double cantRedeclare;

   struct shortRec { int a; };            /* type tag names    */
   union  shortRec { long one;
                     int  two; };
   enum   shortRec { rec1, rec2, rec3 };

   struct repeats  { int   r1;            /* component names   */
                     char  ch;
                     float r1; };

   union  moreRepeats { float  x;
                        int    y;
                        double y; };

   enum   stillOthers { red, black, green, green };

   double f1 ( );                         /* function names    */
   char   f1 (char k);

   printf ("Failed Deviance Test 4.2.2.1\n");
  }
