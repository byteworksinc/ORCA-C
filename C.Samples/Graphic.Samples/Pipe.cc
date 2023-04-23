/****************************************************************
*
*  Pipe
*
*  A simple graphics demo.
*
*  by Mike Westerfield
*
*  Copyright 1987-1989
*  Byte Works, Inc.
*
****************************************************************/

#pragma keep "Pipe"
#pragma lint -1

#include <quickdraw.h>

#define xWidth 20
#define yWidth 10

int main (void)

{
Rect r;					/* drawing rectangle */
int x = xWidth;				/* horizontal width of pipe */
int y = yWidth;				/* vertical width of pipe */
int color = 1;				/* pen color */
int maxX;				/* maximum horizontal pixel */
int maxY;				/* maximum vertical pixel */
int minX;				/* minimum horizontal pixel */
int minY;				/* minimum vertical pixel */
int deltaX = 6;				/* pipe width increment */
int deltaY = 3;				/* pipe depth increment */
int i;

GetPortRect(&r);			/* initialize drawing rectangle */
maxX = r.h2 - xWidth;			/* don't go beyond rect edges */
maxY = r.v2 - yWidth;
minX = r.v1;
minY = r.h1;

for (i = 0; i < 150; ++i) {		/* main loop:  draw pipe, a series of ovals */
   r.h1 = x - xWidth;
   r.h2 = x + xWidth;
   r.v1 = y - yWidth;
   r.v2 = y + yWidth;
   color ^= 3;
   SetSolidPenPat(color);
   PaintOval(&r);
   SetSolidPenPat(0);
   FrameOval(&r);

   x += deltaX;				/* bend pipe as needed to fit within rectangle */
   if (x < xWidth) {
      x = xWidth;
      deltaX = -deltaX;
      }
   else if (x > maxX) {
      x = maxX;
      deltaX = -deltaX;
      }
   y += deltaY;
   if (y < yWidth) {
      y = yWidth;
      deltaY = -deltaY;
      }
   else if (y > maxY) {
      y = maxY;
      deltaY = -deltaY;
      }
   }
}
