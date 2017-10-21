/*                                                                            */
/* Special Conformance Test 13.4.0.1: Verification of stdarg library facility */
/*                                                                            */
/* The tester needs to verify that the values 2, 'c', 1.3, 4.4, and 7.7 are   */
/* printed to standard out.                                                   */
/*                                                                            */

#pragma optimize -1
#include <stdarg.h>

enum types { integer, character, singlePrecision, doublePrecision,
             extendedPrecision, endOfList };


main ()
  {
   int      i  = 2;
   char     ch = 'c';
   float    f  = 1.3;
   double   d  = 4.4;
   extended e  = 7.7;

   enum types typesArray [80];

   void VariablePrint ( enum types *typesArray, ... );


   typesArray [0] = integer;                /* init. array of types of values */
   typesArray [1] = character;              /*   to print                     */
   typesArray [2] = singlePrecision;
   typesArray [3] = doublePrecision;
   typesArray [4] = extendedPrecision;
   typesArray [5] = endOfList;
   VariablePrint ( typesArray, i, ch, f, d, e ); /* call function which takes */
  }                                              /*   variable number args    */


/****************************************************************************/

void VariablePrint ( enum types *typesArray, ... )
  {
   va_list ap;
   enum types nextType;


   va_start (ap, typesArray);           /* initialize variable argument ptr */
   while ( (nextType = *typesArray++) != endOfList )
     {
       switch (nextType)
         {
           case integer:
               printf ("int: %d\n", va_arg (ap, int));
               break;

           case character:
               printf ("char: %c\n", va_arg (ap, int));
               break;

           case singlePrecision:
           case doublePrecision:
           case extendedPrecision:
               printf ("extended: %e\n", va_arg (ap, extended));
               break;

           default:
               printf ("Error in VariablePrint");
               break;

         }  /* end switch */
     }  /* end while */

   va_end (ap);                        /* clean up stack, etc. */
  }
