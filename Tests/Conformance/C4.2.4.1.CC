/* Conformance Test 4.2.4.1:  Ensure the same names in different overloading */
/*                            classes are allowed                            */

struct rect { int h1;                       /* struct, union, enum type tags */
              int v1;                       /* struct/union components       */
              int h2;
              int v2; };

union longOrShort { int  first;
                    long second; };

enum  repeats { h1, v1, h2, v2, first, second };  /* all others: variables, */
                                                  /*   functions, typedefs, */
                                                  /*   enumeration constants*/

main ()
  {
   int    rect;                                   /* can give variables same */
   double longOrShort;                            /*   names as labels, tags,*/
   float  repeats;                                /*   or components         */
   int    label [10];
   union  longOrShort  first;
   enum   repeats      r;

   enum   colors { red, black, green };

   struct person { char name [20];
                   char address [50]; };

   union  floatOrDouble { float  red;
                          double green; };

   int    Label2 (void);                        /* can give functions same */
   char   person (int i);                       /*   names as labels, tags,*/
   float  name (void);                          /*   or components         */

   typedef int    Label3;                       /* can give typedefs same  */
   typedef struct person floatOrDouble;         /*   names as labels, tags,*/
   typedef short  colors;                       /*   or components         */
   typedef float  address;

   Label3        i;
   floatOrDouble x;
   colors        j;
   address       z;

   rect = 8;
   if (rect != 8)
       goto label;

   longOrShort = 3.5;
   if (longOrShort != 3.5)
       goto Label3;

   repeats = (float) 2;
   if (repeats != 2.0)
       goto label;

   for (i = 0; i < 10; i++)
       label [i] = i;

   for (i = 9; i >= 0; i--)
       if (label [i] != i)
           goto label;

   first.first = 10;
   if (first.first != (9+1))
       goto Label2;

   r = second;
   if (r != 5)
       goto Label2;

   strcpy (x.name, "Barbara");
   if ((strcmp (x.name, "Barbara")) != 0)
       goto label;

   j = (int) person (6);
   if (j != 0x36)
       goto Label2;

   j = Label2 ();
   if (j != 5)
       goto Label2;

   z = name ();
   if (z != 1.0)
       goto label;

   printf ("Passed Conformance Test 4.2.4.1\n");
   return;

label: ;
Label2: ;
Label3:
   printf ("Failed Conformance Test 4.2.4.1\n");
  }

/******************************************************************************/

int Label2 (void)

  {
   return 5;
  }


/******************************************************************************/

char person (int i)

  {
   return (i + 0x30);
  }


/******************************************************************************/

float name (void)

  {
   return 1.0;
  }
