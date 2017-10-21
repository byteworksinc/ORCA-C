/* Other file needed to run Special Conformance Test 4.4.1.1 */

#include <math.h>
extern float y;

double G1 (x)
  int x;
  {
   if ( (fabs (y - 8.7)) > 0.0001 )
       return 0.0;
   else
       return (double) x;
  }
