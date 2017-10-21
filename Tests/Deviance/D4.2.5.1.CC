/* Deviance Test 4.2.5.1:  Ensure duplicate declarations of the same     */
/*                         identifiers in the same overloading class and */
/*                         sharing the same scope are detected           */

/* Errors at top level */

#define macro1 "hey"                   /* preprocessor macro names */
#define macro1 8

struct s1 { int a;                     /* type tags */
            int b; };
union  s1 { int   x;
            float y; };
enum   s1 { a, b, c};

struct s2 { int   r;                   /* component names */
            char  ch;
            float r; };
union  u1 { int   x;
            long  x; };

double  a [5];                         /* all other names:  variables, */
float   *a;                            /*   functions, typedef names,  */
extern  int F1 (void);                 /*   enumeration constants      */
int     F1;
typedef float real;
float   real;
enum    flowers { rose, iris, daisy, thistle };
int     rose;

int     i;
typedef int i;
typedef double d1;
typedef int    d1;
float   F2 (int m);
typedef int *F2;
typedef float iris;

double  p;
extern  double p (void);
extern  void Daisy (void);
typedef double doublePrec;
extern  float  doublePrec (void);

int     L [10];
float   one (int abc);
typedef int *two;
enum    numbers { L, one, two };


/* Errors within a function */

main ()
  {
#define macro99  99                    /* preprocessor macro names */
#define macro99  999

   struct ll { char z;                    /* type tags */
               int  m; };
   union  ll { int   x;
               float y; };
   enum   ll { lll, llll, lllll };

   struct jy { float f0;                  /* component names */
               char  ch;
               float f0; };
   union  u1 { int   x [3];
               long  x; };

   double  b [5];                         /* all other names:  variables, */
   float   *b;                            /*   functions, typedef names,  */
   int     Moth (int m0);                 /*   enumeration constants      */
   int     Moth;
   typedef extended ext;
   double  ext;
   enum    people { Joe, Mike, Patty, Jim };
   char    Jim;

   float    floatOne;
   typedef  float floatOne;
   typedef  int *repeatIt;
   typedef  int *repeatIt;
   extended Ext2 (extended ext2);
   typedef  int *Ext2;
   typedef  void Joe;

   long    aLongNum;
   extern  long aLongNum (long longLong);
   extern  void Mike (int Patty);
   typedef unsigned UnSigned;
   extern  int      UnSigned (void);

   extended array [98];
   double   Func1 (double doubleDouble);
   typedef  long *Long;
   enum     objects { array, Long, Func1 };

   printf ("Failed Deviance Test 4.2.5.1\n");
  }

/* Two functions with same name */

/****************************************************************************/

int  Xx (void)
  {
  }

/****************************************************************************/

double Xx (char a)
  {
  }
