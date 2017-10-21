/* Header file for Special Conformance Test 4.5.2.1 */

                                       /* pointers to all the basic types */
extern   int            *intPtr, i;
extern   long           *longPtr, L;
extern   unsigned  int  *uintPtr, ui;
extern   unsigned  long *ulongPtr, ulong;
extern   comp           *compPtr, cmp;
extern   char           *charPtr, ch;
extern   float          *floatPtr, fl;
extern   double         *doublePtr, dbl;
extern   extended       *extPtr, ext;

                                       /* pointers to conglomerate types */

extern   struct s  { int a;
                     long L; } *structPtr, s;
extern   enum   colors  { red, black, green } *colorPtr, color;
extern   union  longOrShort { int first;
                              long second; } *unionPtr, un;
