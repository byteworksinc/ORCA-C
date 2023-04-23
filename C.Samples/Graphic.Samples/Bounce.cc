/****************************************************************
*
*  A simple graphics demo.
*
*  By Phil Montoya and Barbara Allred
*
*  Copyright 1987-1989
*  Byte Works, Inc.
*
****************************************************************/

#pragma keep "Bounce"
#pragma lint -1

#include <quickdraw.h>
#include <orca.h>

#define screenMode 640			/* 640x200 graphics Super HiRes display mode  */
#define copyMode 0			/* pen copy mode */
#define size 6				/* number of points */

/* Global variables */

static int curColor = white;		/* pen color */
static int curSize  = 1;		/* no. points-1 */
static int x[size];			/* initial points */
static int y[size];
static int xv[size], yv[size];		/* move and velocity arrays */
static int maxX, maxY;			/* max X, Y coordinates */
static int minX, minY;			/* min X, Y coordinates */
static Rect r;				/* drawing rectangle */


/****************************************************************
*
*  UpDate - Updates x and y by velocity factors and changes
*           direction if necessary
*
*  Inputs:
*       px  - X location
*       pxv - X velocity
*       py  - Y location
*       pyv - Y velocity
*
****************************************************************/

void UpDate (int *px, int *pxv, int *py, int *pyv)

{
*px += *pxv;				/* move x by velocity factor  */
if ((*px < minX) || (*px > maxX)) {	/* if x is beyond border... */
   *px -= *pxv;				/* ...move back */
   *pxv = -(*pxv);			/* ...change directions */
   }
*py += *pyv;				/* move y by velocity factor */
if ((*py < minY) || (*py > maxY)) {	/* if y is beyond border... */
   *py -= *pyv;				/* ...move back */
   *pyv = -(*pyv);			/* ...change directions */
   }
}


/****************************************************************
*
*  NextPenColor - Changes the pen color
*
****************************************************************/

void NextPenColor (void)

{
curColor++;				/* get next color */
if (curColor > white)			/* if out of colors then start over */
   curColor = black;
SetSolidPenPat(curColor);		/* set the pen to this color */
}


/****************************************************************
*
*  Initialize - initialization for program
*
****************************************************************/

void Initialize (void)

{
int i, j;

SetPenSize(4, 2);			/* use a fatter pen */
SetPenMode(copyMode);			/* use the copy pen mode */
GetPortRect(&r);
maxX = r.h2;   maxY = r.v2;		/* don't go beyond screen edges */
minX = r.h1;   minY = r.v1;

i = maxX - minX;			/* set initial points */
j = maxX >> 1;
x[0] = minX + j + 20;      x[1] = minX + j - 20;
x[2] = x[3] = x[4] = x[5] = minX + j;

i = maxY - minY;
j = maxY >> 1;
y[3] = minY + j + 10;      y[4] = minY + j - 10;
y[0] = y[1] = y[2] = y[5] = minY + j;

for (i = 0, j = 6; i < size; i++) {	/* set velocity factors */
   if (i & 0x0001)			/* if i is odd... */
       j = -j;
   yv [i] = j;
   xv [i] = -j;
   j -= 2;
   }
}


/****************************************************************
*
*  DrawShapes - This is the engine of the demo.
*
****************************************************************/

void DrawShapes (void)

{
int i, j, k;

for (k = white; k >= black; k--) {	/* cycle thru 16 screens */
   SetSolidPenPat(k);			/* set the background color */
   PaintRect(&r);

   /* The number of shapes per screen depends on the size of the shape.    */
   /* The more points a shape has the less times it will be drawn and      */
   /* vice-versa. This keeps the time and density per screen approximately */
   /* the same.                                                            */

   for (i = 0; i <  (((size-curSize) * 38) + 75); i++) {
                                              /* draw this series of shapes */
       NextPenColor ();                       /* change pen colors */
       MoveTo (x[curSize], y[curSize]);       /* initial from position */
       UpDate (x+curSize, xv+curSize, y+curSize, yv+curSize);
       for (j = 0; j < curSize; j++) {        /* draw this shape */
           LineTo (x[j], y[j]);
           UpDate (x+j, xv+j, y+j, yv+j);
           }
       }
   curSize++;                                  /* next shape size */
   if (curSize == size)
       curSize = 1;
   }
}


/****************************************************************
*
*  Program Begins Here
*
****************************************************************/

int main (void)

{
startgraph(screenMode);			/* set up graphics screen */
Initialize();				/* initialize global data */
DrawShapes();				/* draw the shapes */
endgraph();				/* shut down the graphics screen */
return 0;
}
