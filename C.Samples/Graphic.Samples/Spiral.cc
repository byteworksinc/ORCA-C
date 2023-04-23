/****************************************************************
*
*  Spiral
*
*  A simple graphics demo.  Uses the shell STOP command from the
*  debug menu to stop the program early.
*
*  by Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************/

#pragma keep "Spiral"
#pragma lint -1

#include <quickdraw.h>
#include <math.h>

int main (void)

{
float r, theta, rot;
int color = 1;
int stopFlag;
Rect rect;

GetPortRect(&rect);
SetPenSize(3, 1);
for (rot = 0.0002; rot < 0.0005; rot += 0.0001) {
   theta = 0.0;
   r = 40.0;
   MoveTo ((int) (cos (theta) * r * 3) + 160,
           (int) (sin (theta) * r) + 40);
   while (r > 0.0) {
      SetSolidPenPat (color);
      color ^= 3;
      theta += 3.1415926535 / 21.0 + rot;
      LineTo ((int) (cos (theta) * r * 3) + 160,
              (int) (sin (theta) * r) + 40);
      r -= 0.02;
      }
   }
Out: ;
}
