/******************************************************************
*
*   Reversi
*
*   A desktop program for the Apple IIGS.
*
*   Reversi is a board game played between two players.	 This
*   program will play against an opponent (probably you, but you
*   could play it against another program), or it will play
*   itself (useful when you are learning).
*
*   To play the game, the black piece goes first; the human
*   plays black by default (the game allows this to be changed).
*   The object of the game is to try to trap enemy pieces
*   between one of your existing pieces and the new piece to
*   be played.
*
*   The game is so popular and well known that there are several
*   commercial versions available, and all come with rules and
*   basic strategy hints.  Many fine books are also available
*   from your local book store.	 When looking, you should note
*   that the game is also sold under the name Othello.
*
*   The program itself is provided as a real-world example of
*   using the desktop.	Unlike the other samples on this disk,
*   this program was designed as a working game, not as a
*   sample.  For that reason, some problems that can be avoided
*   by careful choice of a sample are handled here - like
*   scrolling without the help of TaskMaster (to avoid scrolling
*   a small part of the Moves window).
*
*   To learn how the program works, start with the main event
*   loop at the end of the program, and examine how it handles
*   each event.	 The move selection procedure, FindMove, is the
*   only place where an event loop is not used.	 That function
*   uses a technique called an alpha-beta search to find the best
*   move.  To understand that search, you may refer to text books
*   on artificial intelligence, or to any one of several fine
*   articles, mostly dealing with chess, that appeared in Byte
*   Magazine in the early 1980's.
*
*   Note that the program is contained in two files:  the first
*   part of the source program is in the file named
*   REVERSI1.CC, while the second part of the source is in the
*   file named REVERSI2.CC.  The ORCA/C append command is used
*   at the end of the first file to automatically begin
*   compilation of the second source file.
*
*   Original Pascal version by Mike Westerfield
*
*   C translation by Barbara Allred
*
*   Copyright 1987-1989
*   Byte Works, Inc.
*
*******************************************************************/

#pragma keep "Reversi"
#pragma lint -1

#include <limits.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include <orca.h>

#include <types.h>
#include <quickdraw.h>
#include <qdaux.h>
#include <misctool.h>
#include <event.h>
#include <control.h>
#include <window.h>
#include <menu.h>
#include <desk.h>
#include <lineedit.h>
#include <dialog.h>

#define squareWidth  52				  /* width of one square      */
#define squareHeight 20				  /* height of one square     */

#define blank	      0				  /* square colors	      */
#define blackPiece    1
#define whitePiece    2
#define border	      3

#define apple_AboutReversi 257			  /* menu names/numbers	      */

#define file_NewGame	   258
#define file_Quit	   259

#define edit_UndoLastMove  270
#define edit_Cut 	   271
#define edit_Copy	   272
#define edit_Paste	   273
#define edit_Clear	   274

#define level_1Ply	   262
#define level_2Ply	   263
#define level_3Ply	   264
#define level_4Ply	   265
#define level_5Ply	   266
#define level_6Ply	   267
#define level_7Ply	   268
#define level_8Ply	   269

#define options_SelfPlay 	   280
#define options_ComputerPlaysWhite 281
#define options_Pass		   282
#define options_ShowScoreWindow	   283
#define options_ShowMovesWindow	   284


typedef int BOOL;				    /* simulate boolean types */

enum   alertKind { norml, stop, note, caution }; 	   /* kinds of alerts */
							   /* move list:      */
struct moveListType { int  num;				   /*	#legal moves  */
		      char moves [60]; };		   /*	list of moves */


/* Global variables */

static int  ply = 1;		      /* set initial playing level to 1	      */
static int  color = whitePiece;	      /* color the computer plays	      */
static int  currentColor;	      /* color to move next		      */
static int  movesMade;		      /* # moves, by playing level, made      */
static int  topMove;		      /* 1st visible move in moves list	      */
static int  event;		      /* event #; returned by TaskMaster      */
static int  moveHeight;		      /* current height of move window	      */
static int  charHeight;		      /* size of a character		      */
static int  moves [61];		      /* list of moves made		      */

static int  disp  [8] =		      /* move displacements		      */
{ 9, 10, 11, -1, 1, -9, -10, -11 };

static int  bSc	  [300] =	      /* square scores for 3 portions of game */
{    0,	   0,	 0,    0,    0,	   0,	 0,    0,    0,	   0,	 0,  500,  -20,
   100,	  50,	50,  100,  -20,	 500,	 0,    0,  -20, -250,	-2,   -2,   -2,
    -2, -250,  -20,    0,    0,	 100,	-2,   30,   10,	  10,	30,   -2,  100,
     0,	   0,	50,   -2,   10,	   2,	 2,   10,   -2,	  50,	 0,    0,   50,
    -2,	  10,	 2,    2,   10,	  -2,	50,    0,    0,	 100,	-2,   30,   10,
    10,	  30,	-2,  100,    0,	   0,  -20, -250,   -2,	  -2,	-2,   -2, -250,
   -20,	   0,	 0,  500,  -20,	 100,	50,   50,  100,	 -20,  500,    0,    0,
     0,	   0,	 0,    0,    0,	   0,	 0,    0,    0,	   0,	 0,    0,    0,
     0,	   0,	 0,    0,    0,	   0,	 0,  500,  -20,	 200,	50,   50,  200,
   -20,	 500,	 0,    0,  -20, -250,	15,   10,   10,	  15, -250,  -20,    0,
     0,	 200,	15,   35,   20,	  20,	35,   15,  200,	   0,	 0,   50,   10,
    20,	  15,	15,   20,   10,	  50,	 0,    0,   50,	  10,	20,   15,   15,
    20,	  10,	50,    0,    0,	 200,	15,   35,   20,	  20,	35,   15,  200,
     0,	   0,  -20, -250,   15,	  10,	10,   15, -250,	 -20,	 0,    0,  500,
   -20,	 200,	50,   50,  200,	 -20,  500,    0,    0,	   0,	 0,    0,    0,
     0,	   0,	 0,    0,    0,	   0,	 0,    0,    0,	   0,	 0,    0,    0,
     0,	   0,	 0,  400,  -20,	 100,	75,   75,  100,	 -20,  400,    0,    0,
   -20, -300,	60,   10,   10,	  60, -300,  -20,    0,	   0,  100,   60,   50,
     5,	   5,	50,   60,  100,	   0,	 0,   75,   10,	   5,	30,   30,    5,
    10,	  75,	 0,    0,   75,	  10,	 5,   30,   30,	   5,	10,   75,    0,
     0,	 100,	60,   50,    5,	   5,	50,   60,  100,	   0,	 0,  -20, -300,
    60,	  10,	10,   60, -300,	 -20,	 0,    0,  400,	 -20,  100,   75,   75,
   100,	 -20,  400 };

static BOOL done;		      /* are we done yet?		      */
static BOOL selfPlay;		      /* computer-human or computer-computer  */
static BOOL movesLeft;		      /* are there legal moves left?	      */
static BOOL updateMoves; 	      /* does entire list need updating?      */
static BOOL showScoreWindow;	      /* is scoreWindow visible? 	      */
static BOOL showMovesWindow;	      /* is movesWindow visible? 	      */
static BOOL movesNotFront;	      /* is Moves window the front window?    */

static char board [100]; 	      /* main game board 		      */
static char msg	  [256]; 	      /* for builing alert strings	      */

				      /* strings for SetItem calls	      */
static char selfPlayStr	       [] = "--Self Play";
static char computerPlayStr    [] = "--Play Computer";
static char computerPlaysBlack [] = "--Computer Plays Black";
static char computerPlaysWhite [] = "--Computer Plays White";

static WmTaskRec lastEvent;		 /* last event returned in event loop */

static ParamList wParms =			  /* parameters for NewWindow */
       { 78, 0x80E4, NULL, 0, 0, 0, 0, 0, NULL, 0, 0, squareHeight * 8,
	 squareWidth * 8, squareHeight * 8, squareWidth * 8, 0, 0, 0, 0, 0, 0,
	 NULL, NULL, NULL, 32, 32, 32 + squareHeight * 8, 32 + squareWidth * 8,
	 (GrafPortPtr) topMost, NULL };
static ParamList boardParms, scoreParms, movesParms;	  /* window parameter */
							  /*   records	      */

static GrafPortPtr boardWindow;		/* pointer to the game board window   */
static GrafPortPtr scoreWindow;		/* pointer to the score window	      */
static GrafPortPtr movesWindow;		/* pointer to the Moves window	      */

static CtlRecHndl growHandle;		/* Moves window's grow box            */
static CtlRecHndl vScrollHandle; 	/* Moves window's vertical scroll bar */


/* Utility routines */

/****************************************************************
*
* DoAlert - Create an alert box
*
* Input:
*      kind - kind of alert
*      msg  - alert message
*
****************************************************************/
void DoAlert (enum alertKind kind, char *msg)
{
static ItemTemplate button =				      /* button item  */
       { 1, 36, 15, 0, 0, buttonItem, "\pOK", 0, 0, NULL };

static ItemTemplate message =				      /* message item */
       { 100, 5, 100, 90, 280, itemDisable+statText, NULL, 0, 0, NULL };

static AlertTemplate alertRec =				      /* alert box    */
       { 50, 180, 107, 460, 2, 0x80, 0x80, 0x80, 0x80, NULL, NULL, NULL };


SetForeColor (0);					   /* set text colors */
SetBackColor (15);

message.itemDescr	= msg;				/* init. non-constant */
alertRec.atItemList [0] = (ItemTempPtr) &button; 	/*   template fields  */
alertRec.atItemList [1] = (ItemTempPtr) &message;

switch (kind) {
   case norml:	   Alert (&alertRec, NULL);
		   break;

   case stop:	   StopAlert (&alertRec, NULL);
		   break;

   case note:	   NoteAlert (&alertRec, NULL);
		   break;

   case caution:   CautionAlert (&alertRec, NULL);
		   break;

   default:	   printf ("Error in DoAlert\n");
		   exit (-1);
		   break;
   }
} /* DoAlert */


/****************************************************************
*
* Even - Returns an even number by incrementing odd parameters;
*	 for move list calculations
*
* Input:
*      i - integer tested for being even
*
* Output:
*      i if i is even; i+1 if i is odd
*
****************************************************************/
int Even (int i)
{
if (i & 0x0001)
   return i+1;
else
   return i;
} /* Even */


/* Routines involved in playing the game */

/****************************************************************
*
* Plot - Plot a point
*
* Input:
*      h - horizontal pixel of point
*      v - vertical pixel of point
*
****************************************************************/
void Plot (int h, int v)
{
MoveTo (h, v);
LineTo (h, v);
} /* Plot */


/****************************************************************
*
* DrawSquare - Draw a square on the game board
*
* Input:
*      square - number of square to draw
*      col    - color of square to draw
*
****************************************************************/
void DrawSquare (int square, int col)
{
#define penBlack 0					/* pen colors	      */
#define penGreen 2
#define penWhite 3

Rect r;							/* square's rectangle */

StartDrawing (boardWindow);			 /* draw to our window	      */
r.h2 = (square % 10) * squareWidth - 1;		 /* set up square's rectangle */
r.v2 = (square / 10) * squareHeight - 1;
r.h1 = r.h2 - squareWidth + 1;
r.v1 = r.v2 - squareHeight + 1;

SetSolidPenPat (penGreen);			 /* draw background of square */
PaintRect (&r);
SetSolidPenPat (penBlack);			 /* draw edge of square	      */
MoveTo (r.h1, r.v2);
LineTo (r.h2, r.v2);
LineTo (r.h2, r.v1);

switch (square) {			   /* draw "corner" dots, if required */

   case 22: case 26: case 62: case 66:
       Plot (r.h2-1, r.v2-1);
       break;

   case 23: case 27: case 63: case 67:
       Plot (r.h1, r.v2-1);
       break;

   case 32: case 36: case 72: case 76:
       Plot (r.h2-1, r.v1);
       break;

   case 33: case 37: case 73: case 77:
       Plot (r.h1, r.v1);
       break;

   default:
       break;
   }

if (col != blank) {				    /* draw the piece, if any */
   if (col == whitePiece)
       SetSolidPenPat (penWhite);
   PaintOval (&r);
   }
} /* DrawSquare */


/****************************************************************
*
* DrawBoard - Draw (or redraw) the entire game board
*
****************************************************************/

void DrawBoard (void)
{
int i;							     /* loop variable */
int col; 						     /* column #      */

for (i = 11; i <= 88; i++) {
   col = i % 10;
   if ((col != 0) && (col != 9))
       DrawSquare (i, board[i]);
   }
} /* DrawBoard */


/****************************************************************
*
* GetMoves - Create a list of legal moves
*
* Input:
*      board	- game board to search for moves
*      color	- color of piece for which conducting search
*      moveList - record of moves to make
*
****************************************************************/
void GetMoves (char board[], int color, struct moveListType *moveList)
{
int index;				  /* square being checked	      */
int tindex;				  /* work index			      */
int enemyColor = color ^ 3;		  /* temp variable for enemy color    */
int dir; 				  /* direction being checked	      */
struct moveListType lMoveList;		  /* local move list - for efficiency */

lMoveList.num = 0;				     /* no moves so far	      */
for (index = 11; index < 90; index++) {		     /* loop over all squares */

   if (board[index] == blank)			  /* check only empty squares */

       for (dir = 0; dir < 8; dir++) {		  /* loop in all 8 directions */
	   tindex = index + disp[dir];		  /* see if there's a capture */
	   if (board[tindex] == enemyColor) {	  /*   in this direction      */
	       while (board[tindex] == enemyColor)	 /* skip enemy pieces */
		   tindex += disp[dir];
	       if (board[tindex] == color) {	    /* if last piece is ours, */
						    /*	 move is legal	      */
		   lMoveList.moves [lMoveList.num] = index;
		   lMoveList.num++;
		   goto Out;
		   }
	       }
	   }
Out: ;
 }
*moveList = lMoveList;					  /* return move list */
} /* GetMoves */


/****************************************************************
*
* CheckForDone - Check if game is over
*
****************************************************************/
void CheckForDone (void)
{
struct moveListType moveList;		   /* for checking # of moves	      */
char string [10];			   /* for converting scores to strings*/
int  wcnt, bcnt; 			   /* # pieces for each side	      */
int  i;					   /* loop variable		      */

GetMoves (board, whitePiece, &moveList);
if (! moveList.num) {
   GetMoves (board, blackPiece, &moveList);
   if (! moveList.num) {
       for (i = 11, wcnt = 0, bcnt = 0; i < 90; i++) {
	   if (board[i] == whitePiece)
	       wcnt++;
	   else if (board[i] == blackPiece)
	       bcnt++;
	   }
       if (wcnt == bcnt)
	   strcpy (msg, "The game is overs. It\ris a draw.");

       else {
	   if (wcnt > bcnt)
	       strcpy (msg, "White");
	   else
	       strcpy (msg, "Black");
	   strcat (msg, " wins by a score\rof ");
	   sprintf (string, "%d", bcnt); 	       /* convert scores to strings */
	   strcat (msg, string);
	   strcat (msg, " to ");
	   sprintf (string, "%d", wcnt);
	   strcat (msg, string);
	   }
       DoAlert (note, c2pstr (msg));
       movesLeft = false;
       }
   }
} /* CheckForDone */


/****************************************************************
*
* ScoreEdge - Score an edge of the game board by these rules:
*
*   1. An edge must have at least one empty square to be scored.
*   2. If there is a single space between friendly pieces, score -100.
*   3. If there are two spaces between friendly pieces, score 30.
*   4. If there are three spaces between friendly pieces, score -50.
*   5. If there is a solid line of enemy pieces between friendly
*      pieces, score -150;
*
* Input:
*      edge - array of edge squares to score
*
* Output:
*      score of edges
*
****************************************************************/
int ScoreEdge (int edge[])
{
BOOL atLeastOneBlank;			     /* for checking rule #1	      */
int  s = 0, rs;				     /* for computing scores	      */
int  enemyColor; 			     /* temp variable for enemy color */
int  i, j;				     /* loop variables		      */

atLeastOneBlank = false; 				  /* check rule 1     */
for (i = 1; i < 9; i++)
   atLeastOneBlank = atLeastOneBlank || (edge[i] == blank);

if (atLeastOneBlank)					  /* check all edge   */
   for (i = 1; i < 8; i++)				  /*   positions      */
       if ((edge[i] == blackPiece) || (edge[i] == whitePiece)) {
	   enemyColor = edge[i] ^ 3;
	   j = i + 1;
	   if (edge[j] == enemyColor) {			  /* check rule 5     */
	       while (edge[j] == enemyColor)
		   j++;
	       if (edge[j] == edge[i])
		   if (enemyColor == whitePiece)
		       s -= 150;
		   else
		       s += 150;
	       }
	   else if (edge[j] == blank) {			  /* check rules 2..4 */
	       while (edge[j] == blank)
		   j++;
	       if (edge[j] == edge[i]) {
		   switch (j - i) {
		       case 2: rs = -100;		  /* score rule 2     */
			       break;

		       case 3: rs = 30;			  /* score rule 3     */
			       break;

		       case 4: rs = -50; 		  /* score rule 4     */
			       break;

		       default:	 break;
		       }

		   if (edge[i] == whitePiece)
		       s -= rs;
		   else
		       s += rs;
		   } /* if */
	       } /* else if */
	   } /* if */
   return s;
} /* ScoreEdge */


/****************************************************************
*
* Score - Score the game board passed
*
* Input:
*      board - game board to score
*
* Output:
*      score of game board
*
****************************************************************/
int Score (char board[])
{
int s = 0, rs;					/* temp variables for scoring */
int pi;						/* game portion index	      */
int numPieces = 0;				/* # pieces on board	      */
int edge [10];					/* for scoring edges	      */
int i;						/* loop variable 	      */

for (i = 11; i < 90; i++)			/* loop over all squares      */
   if (board[i] == whitePiece) { 		/* add 4 for black, decrement */
       s -= 4;					/*   4 for white 	      */
       numPieces++;
       }
   else if (board[i] == blackPiece) {
       s += 4;
       numPieces++;
       }

if (numPieces < 24)			       /* set index into board scores */
   pi = 0;				       /*   by part of game this is   */
else if (numPieces < 44)
   pi = 100;
else
   pi = 200;

for (i = 11; i < 90; i++)		       /* loop over all squares,      */
					       /*    summing square values    */
   if ((board[i] == blackPiece) || (board[i] == whitePiece)) {

       if ((i == 12) || (i == 21) || (i == 22)) /* squares adjacent to corners */
	 {				       /*   get special treatment     */
	   if ((board[11] == blackPiece) || (board[11] == whitePiece))
	       rs = 10;
	   else
	       rs = bSc[pi+i];
	   }

       else if ((i == 17) || (i == 27) || (i == 28)) {
	   if ((board[18] == blackPiece) || (board[18] == whitePiece))
	       rs = 10;
	   else
	       rs = bSc[pi+i];
	   }

       else if ((i == 71) || (i == 72) || (i == 82)) {
	   if ((board[81] == blackPiece) || (board[81] == whitePiece))
	       rs = 10;
	   else
	       rs = bSc[pi+i];
	   }

       else if ((i == 77) || (i == 78) || (i == 87)) {
	   if ((board[88] == blackPiece) || (board[88] == whitePiece))
	       rs = 10;
	   else
	       rs = bSc[pi+i];
	   }

       else
	   rs = bSc[pi+i];

       if (board[i] == whitePiece)
	   s -= rs;
       else
	   s += rs;
       }

for (i = 0; i < 10; i++) 				 /* score top edge    */
   edge[i] = board[10+i];
s += ScoreEdge (edge);

for (i = 0; i < 10; i++) 				 /* score bottom edge */
   edge[i] = board[i+80];
s += ScoreEdge (edge);

for (i = 0; i < 10; i++) 				 /* score left edge   */
   edge[i] = board[1+i*10];
s += ScoreEdge (edge);

for (i = 0; i < 10; i++) 				 /* score right edge  */
   edge[i] = board[8+i*10];
s += ScoreEdge (edge);

return s;						 /* return the score  */
} /* Score */


/****************************************************************
*
* MakeAMove - Make a move on the main playing board
*
* Input:
*      index - board index of move to make
*      col   - color of player making move
*
****************************************************************/
void MakeAMove (int index, int col)
{
#define pause 100			     /* index for pause		      */

int dir; 				     /* loop variable for directions  */
int tindex;				     /* temp index; for captures      */
int enemyColor;				     /* temp variable for enemy color */
int i;					     /* loop variable		      */

moves[++movesMade] = index;			    /* record the move	      */
DrawSquare (index, col); 			    /* flash the piece played */
for (i = 0; i < pause; i++)
   ;
DrawSquare (index, blank);
for (i = 0; i < pause; i++)
    ;
DrawSquare (index, col);

board[index] = col;				/* make the move on the board */
enemyColor   = col ^ 3;				/* set enemy color	      */
for (dir = 0; dir < 8; dir++) {			/* loop in all 8 directions   */
   tindex = index + disp[dir];			/* see if there's a capture   */
   if (board[tindex] == enemyColor) {		/*   in this direction	      */

       while (board[tindex] == enemyColor)	/* skip enemy pieces	      */
	   tindex += disp[dir];

       if (board[tindex] == col) {	    /* if last piece is ours, capture */
	   tindex = index + disp[dir];

	   while (board[tindex] != col) {
	       DrawSquare (tindex, col);
	       board[tindex]  = col;
	       tindex	     += disp[dir];
	       } /* while */
	   } /* if */
       } /* if */
   } /* for */
} /* MakeAMove */


/****************************************************************
*
* EndScore - Compute an end-game score (no more moves) for passed board
*
* Input:
*      board - game board to score
*
* Output:
*      score of game board passed
*
****************************************************************/
int EndScore (char board[])
{
int s = 0;						/* work copy of score */
int i;							/* loop variable      */

for (i = 11; i < 90; i++)			/* count difference in pieces */
   if (board[i] == whitePiece)
       s--;
   else if (board[i] == blackPiece)
       s++;

if (s < 0)					      /* set the return value */
   return INT_MIN + 65 + s;
else if (s > 0)
   return INT_MAX - 65 + s;
else
   return 0;
} /* EndScore */


static char boardName [] = "\pReversi";		/* names of Reversi's windows */
static char scoreName [] = "\pScores";
static char movesName [] = "\pMoves";


/****************************************************************
*
* ScoreMove - Find the score for a particular move
*
* Input:
*      board - game board to make move on
*      index - move to make
*      s     - best score at previous level
*      col   - color computer is playing
*      level - current playing level
*
* Output:
*      score for chosen move
*
****************************************************************/
int ScoreMove (char board[], int index, int s, int col, int level)
{
int bscore;				    /* best score from this level     */
int bmove;				    /* best move from this level      */
int enemyColor;				    /* color of the enemy peices      */
int dir; 				    /* direction loop variable	      */
int tindex;				    /* temp board index; for captures */
int i;					    /* loop variable		      */
struct moveListType moveList;		    /* list of legal moves	      */
char   lBoard [100];			    /* local copy of game board	      */

/* Make the move passed */

memcpy (lBoard, board, 100);		   /* make local copy of passed board */

enemyColor = col ^ 3;			      /* set enemy color 	      */
if (index) {				      /* if there was a move, make it */
   lBoard[index] = col;			      /* make the move on the board   */
   for (dir = 0; dir < 8; dir++) {	      /* loop in all 8 directions     */
       tindex = index + disp[dir];	      /* see if there's a capture in  */
       if (lBoard[tindex] == enemyColor) {    /*   this direction	      */
	   while (lBoard[tindex] == enemyColor)		  /* skip enemy pieces */
	       tindex += disp[dir];
	   if (lBoard[tindex] == col) {	    /* if last piece is ours, capture */
	       tindex = index + disp[dir];
	       while (lBoard[tindex] != col) {
		   lBoard[tindex] =  col;
		   tindex	+= disp[dir];
		   }
	       } /* if */
	   } /* if */
       } /* for */
   } /* if */


/* Part 2:  Score the board */

if (level == ply)			  /* if at max depth, score is static */
   return Score (lBoard);

else {					  /* else pick from available moves   */
   GetMoves (lBoard, enemyColor, &moveList);	 /* get a list of legal moves */
   if (enemyColor == whitePiece) 	 /* init. score is worst possible, so */
       bscore = INT_MAX; 		 /*  that any alternative is selected */
   else
       bscore = INT_MIN;
   if (! moveList.num) { 		/* if no moves, check for end of game */
       GetMoves (lBoard, col, &moveList);
       if (! moveList.num)
	   bscore = EndScore (lBoard);
       else
	   bscore = ScoreMove (lBoard, 0, bscore, enemyColor, level+1);
       }

   else {
       for (i = 0; i < moveList.num; i++) {	/* scan/score available moves */
	   s = ScoreMove (lBoard, moveList.moves[i], bscore, enemyColor,
			  level+1);
	   if (enemyColor == whitePiece) {     /* if this is the best so far, */
					       /*    remember the move	      */
	       if (s < bscore) {
		   bscore = s;
		   bmove  = moveList.moves[i];
		   }
	       }
	    else {
	       if (s > bscore) {
		   bscore = s;
		   bmove  = moveList.moves[i];
		   }
	       } /* else */
	   } /* for */
       } /* else */
   return bscore;
   } /* else */
} /* ScoreMove */


/****************************************************************
*
* FindMove - Make a computer-generated move
*
* Input:
*      col - color computer is playing
*
****************************************************************/
void FindMove (int col)
{
struct moveListType moveList;		     /* list of legal moves	   */
int bmove;				     /* best move from this level  */
int bscore;				     /* best score from this level */
int s;					     /* work copy of score	   */
int i;					     /* loop variable		   */

WaitCursor ();				     /* change to the watch cursor */
GetMoves (board, col, &moveList);	     /* get a list of legal moves  */
if (moveList.num == 1)			/* if there's only 1 move, make it */
   MakeAMove (moveList.moves[0], col);
else if (moveList.num > 1) {		/* if there's more than 1, initial */
   if (col == whitePiece)		/*   score is worst possible, so   */
       bscore = INT_MAX; 		/*   any alternative is selected   */
   else
       bscore = INT_MIN;

   for (i = 0; i < moveList.num; i++) {		/* scan/score available moves */
       s = ScoreMove (board, moveList.moves[i], bscore, col, 1);
       if (col == whitePiece) {
	   if (s < bscore) {			   /* if this is best so far, */
	       bscore = s;			   /*	remember the move     */
	       bmove = moveList.moves[i];
	       }
	   }
       else {					   /* if color is black then  */
	   if (s > bscore) {
	       bscore = s;
	       bmove  = moveList.moves[i];
	       }
	   }
       }
   MakeAMove (bmove, col);			  /* make the best move found */
   }

else {							    /* no legal moves */
   strcpy (msg, "\pI cannot move, so I\rmust pass.\r");
   InitCursor ();
   DoAlert (note, msg);
   WaitCursor ();
   }

InitCursor ();					  /* back to the arrow cursor */
CheckForDone ();
} /* FindMove */


/****************************************************************
*
* NewGame - Set up the board for a new game
*
****************************************************************/
void NewGame (void)
{
Rect r;				       /* rectangle for clearing Moves window */
GrafPortPtr port;		       /* graph port pointer		      */
int i;				       /* loop variable			      */
int col, row;			       /* row, column numbers		      */

static void DrawMoves (void);	       /* subroutines called by NewGame	      */
static void DrawScore (void);

/* Write the contents of the Scores window */

for (i = 0; i < 100; i++) {			 /* initialize the game board */
   col = i % 10;
   row = i / 10;
   if ((!row) || (!col) || (row == 9) || (col == 9))
       board[i] = border;
   else
       board[i] = blank;
   }
board[44] = whitePiece;	   board[55] = whitePiece;
board[45] = blackPiece;	   board[54] = blackPiece;

currentColor = blackPiece;		 /* black moves first		      */
movesLeft    = true;			 /* the game is not over yet...	      */
movesMade    = 0;			 /* empty the moves list 	      */
topMove	     = 1;			 /* first visible move in moves list  */
updateMoves  = true;			 /* draw entire list		      */

if (showMovesWindow) {			 /* if move list is visible, clear it */
  port = GetPort ();			 /* save the graph port		      */
  StartDrawing (movesWindow);		 /* draw to the Moves window	      */
  GetPortRect (&r);			 /* get the rectangle		      */
  EraseRect (&r);			 /* erase the window's contents       */
  DrawControls (movesWindow);		 /* draw the controls		      */
  SetPort (port);			 /* restore the old graph port	      */
  DrawMoves ();				 /* draw the pieces		      */
  }
if (showScoreWindow)
   DrawScore (); 			 /* redraw the Scores window	      */
} /* NewGame */


/* Initialization routines */


/****************************************************************
*
* InitMenus - Create and draw the initial menu bar
*
****************************************************************/
void InitMenus (void)
{
InsertMenu (NewMenu (">>  Options  \\N5\r"	   /* create the Options menu */
		     "--Self Play\\N280\r"
		     "--Computer Plays Black\\N281\r"
		     "---\\N514D\r"
		     "--Pass\\N282\r"
		     "--Show Score Window\\N283\r"
		     "--Show Moves Window\\N284\r"
		     ".\r"), 0);

InsertMenu (NewMenu (">>  Level  \\N4\r" 	     /* create the Level menu */
		     "--1 Ply\\N262\r"
		     "--2 Ply\\N263\r"
		     "--3 Ply\\N264\r"
		     "--4 Ply\\N265\r"
		     "--5 Ply\\N266\r"
		     "--6 Ply\\N267\r"
		     "--7 Ply\\N268\r"
		     "--8 Ply\\N269\r"
		     ".\r"), 0);

InsertMenu (NewMenu (">>  Edit  \\N3\r"		      /* create the Edit menu */
		     "--Undo Last Move\\N270D*Zz\r"
		     "---\\N512D\r"
		     "--Cut\\N271D*Xx\r"
		     "--Copy\\N272D*Cc\r"
		     "--Paste\\N273D*Vv\r"
		     "--Clear\\N274D\r"
		     ".\r"), 0);

InsertMenu (NewMenu (">>    File  \\N2\r"	      /* create the File menu */
		     "--New Game\\N258*Nn\r"
		     "---\\N513D\r"
		     "--Quit\\N259*Qq\r"
		     ".\r"), 0);

InsertMenu (NewMenu (">>@\\XN1\r"		     /* create the Apple menu */
		     "--About Reversi\\N257\r"
		     "---\\N513D\r"
		     ".\r"), 0);

FixAppleMenu (1);			       /* add desk accessories	      */
FixMenuBar ();				       /* draw the completed menu bar */
DrawMenuBar ();
CheckMItem (true, level_1Ply);		       /* check ply 1		      */
} /* InitMenus */


/****************************************************************
*
* InitVariables - Initialize global variables
*
****************************************************************/
void InitVariables (void)
{
Rect r;				     /* rectangle for finding height of chars */

CharBounds ('A', &r);			    /* find the height of a character */
charHeight = r.h2 - r.h1;
NewGame ();				   /* set up the board for a new game */
}


/****************************************************************
*
* InitWindow - Draw the game board's window
*
****************************************************************/
void InitWindow (void)
{
#define scoreWidth 96			     /* width of Score, Moves windows */

Rect r;					     /* for setting sizes of controls */

boardParms	  = wParms;			   /* create the board window */
boardParms.wTitle = boardName;
boardWindow	  = NewWindow (&boardParms);

scoreParms		= wParms;		  /* create the Scores window */
scoreParms.wTitle	= scoreName;
scoreParms.wFrameBits	= 0xC0C4;
scoreParms.wDataH	= 29;
scoreParms.wDataW	= scoreWidth;
scoreParms.wMaxH 	= 29;
scoreParms.wMaxW 	= scoreWidth;
scoreParms.wPosition.v1 = 32;
scoreParms.wPosition.h1 = 640 - 32 - scoreWidth;
scoreParms.wPosition.v2 = 61;
scoreParms.wPosition.h2 = 640 - 32;
scoreWindow		= NewWindow (&scoreParms);

movesParms		= scoreParms;		   /* create the Moves window */
movesParms.wTitle	= movesName;
movesParms.wDataH	= 112;
movesParms.wPosition.v1 = 80;
movesParms.wPosition.v2 = 192;
movesWindow		= NewWindow (&movesParms);

r.h1 = scoreWidth - 23;					 /* create a grow box */
r.h2 = scoreWidth + 1;
r.v1 = 100;    r.v2 = 113;
growHandle = NewControl (movesWindow, &r, NULL, 0, 0, 0, 0, (void *) 0x08000000,
			 0L, NULL);

r.v1 = 0;      r.v2 = 101;				 /* create scroll bar */
vScrollHandle = NewControl (movesWindow, &r, NULL, 3, 0, 112, 25,
			    (void *) 0x06000000, 0L, NULL);

moveHeight = 112;			  /* set height of window	      */
SelectWindow (boardWindow);		  /* make game board the front window */
} /* InitWindow */


/* Action Routines */


/****************************************************************
*
* WriteMove - Write a move on the screen
*
* Input:
*      move - move to write
*
****************************************************************/
void WriteMove (int move)
{
printf ("%c%d ", (char) (move % 10 - 1 + 'A'), 9 - move / 10);
} /* WriteMove */


/****************************************************************
*
* DrawMoves - Write the contents of the Moves window
*
****************************************************************/
void DrawMoves (void)
{
GrafPortPtr port, p2;			      /* graphics ports		      */
CtlRecHndl  ctl; 			      /* for finding scroll bar	      */
Rect r;					      /* rectangle for drawing colors */
int  i, n;				      /* index variables 	      */

if (showMovesWindow) {
   port = GetPort ();			     /* save the current graph port   */
   StartDrawing (movesWindow);		     /* draw to the Score window      */
   SetForeColor (0);			     /* black pen on white background */
   SetBackColor (15);

   if (updateMoves) {
       SetSolidPenPat (0);			  /* draw black column header */
       r.v1 = 5;   r.h1 = 26;
       r.v2 = 13;  r.h2 = 40;
       PaintOval (&r);
       r.v1 = 5;   r.h1 = 47;			  /* draw white column header */
       r.v2 = 13;  r.h2 = 61;
       PaintOval (&r);
       SetSolidPenPat (15);
       r.v1 = 6;   r.h1 = 48;
       r.v2 = 12;  r.h2 = 60;
       PaintOval (&r);
       }

   if (movesMade > 0) {					    /* draw the moves */
       MoveTo (2, 25);
       i = topMove;
       n = (i + 1) / 2;

       while (i <= movesMade) {
	   if ((updateMoves) || (i > movesMade - 2)) {
	       if (n < 10)
		   printf (" ");
	       printf ("%2d: ", n);
	       WriteMove (moves[i]);
	       if (i + 1 <= movesMade)
		   WriteMove (moves[i+1]);
	       else
		   printf ("      ");
	       }

	   printf ("\r");
	   n++;
	   i += 2;
	   }
       printf ("                \r");	 /* blank the last line (for scrolls) */
       SetCtlParams (Even (movesMade) / 2 * charHeight, moveHeight - 25,
		     vScrollHandle);		     /* update the thumb size */
       SetPort (port);				/* restore the old graph port */
       }
   updateMoves = false;		       /* complete update is no longer needed */
   }
} /* DrawMoves */


/****************************************************************
*
* DrawScore - Write the contents of the Score window
*
****************************************************************/
void DrawScore (void)
{
int i;						     /* loop variable	      */
int wcnt, bcnt;					     /* for counting pieces   */
GrafPortPtr port;				     /* current graphics port */

if (showScoreWindow) {
   port = GetPort ();			     /* save the graph port	      */
   StartDrawing (scoreWindow);		     /* draw to the score window      */
   SetForeColor (0);			     /* black pen on white background */
   SetBackColor (15);
   MoveTo (2, 10);			     /* start at upper left corner    */

   for (i = 11, wcnt = 0, bcnt = 0; i < 90; i++) /* count the pieces on board */
       if (board[i] == whitePiece)
	   wcnt++;
       else if (board[i] == blackPiece)
	   bcnt++;
   printf ("White: %d  \rBlack: %d  \r", wcnt, bcnt);	  /* write the scores */
   printf ("Score: %d          \r", Score (board));
   SetPort (port);				/* restore the old graph port */
   }
} /* DrawScore */


/****************************************************************
*
* MenuShowMovesWindow - Hide or show the Moves window
*
****************************************************************/
void MenuShowMovesWindow (void)
{
GrafPortPtr port;				     /* current graphics port */

showMovesWindow = ! showMovesWindow;		   /* reverse window's status */
CheckMItem (showMovesWindow, options_ShowMovesWindow);
ShowHide (showMovesWindow, movesWindow);
if (showMovesWindow) {				    /* if visible, draw it... */
   updateMoves = true;				       /* draw the moves list */
   DrawMoves ();
   port = GetPort ();				       /* save the graph port */
   StartDrawing (movesWindow);			       /* redraw the controls */
   SetPort (port);
   }
SelectWindow (boardWindow);
} /* MenuShowMovesWindow */


/****************************************************************
*
* MenuShowScoreWindow - Hide or show the Score window
*
****************************************************************/
void MenuShowScoreWindow (void)
{
showScoreWindow = ! showScoreWindow;
CheckMItem (showScoreWindow, options_ShowScoreWindow);
ShowHide (showScoreWindow, scoreWindow);
SelectWindow (boardWindow);
DrawScore ();
} /* MenuShowScoreWindow */


/****************************************************************
*
* MenuAbout - Show the About dialog
*
****************************************************************/
void MenuAbout (void)
{
strcpy (msg, "\pReversi 1.0\rCopyright 1989\rByte Works, Inc.\r"
	     "\rBy Mike Westerfield");
DoAlert (note, msg);
} /* MenuAbout */


/****************************************************************
*
* MenuColor - Change the color the computer plays
*
****************************************************************/
void MenuColor (void)
{
if (color == whitePiece) {
   SetMItem (computerPlaysWhite, options_ComputerPlaysWhite);
   color = blackPiece;
   }
else {
   SetMItem (computerPlaysBlack, options_ComputerPlaysWhite);
   color = whitePiece;
   }
} /* MenuColor */


/****************************************************************
*
* MenuPass - Player wants to pass
*
****************************************************************/
void MenuPass (void)
{
struct moveListType moveList;	       /* for seeing if there are legal moves */

GetMoves (board, currentColor, &moveList);	 /* get a list of legal moves */
if (! moveList.num)			  /* OK to pass if there are no moves */
   currentColor ^= 3;
else {					  /* error to pass if there are moves */
   strcpy (msg, "\pYou have legal moves\rso you cannot pass.\r");
   DoAlert (stop, msg);
   }
} /* MenuPass */


/****************************************************************
*
* MenuSelfPlay - Change the current playing mode
*
****************************************************************/
void MenuSelfPlay (void)
{
selfPlay = ! selfPlay;
if (selfPlay)
   SetMItem (computerPlayStr, options_SelfPlay);
else
   SetMItem (selfPlayStr, options_SelfPlay);
} /* MenuSelfPlay */


/****************************************************************
*
* MenuSetPly - Change the current playing level
*
* Input:
*      newPly - menu number of playing level selected
*
****************************************************************/
void MenuSetPly (int newPly)
{
CheckMItem (false, ply + level_1Ply - 1);		 /* uncheck old ply   */
CheckMItem (true, newPly);				 /* check new ply     */
ply = newPly - level_1Ply + 1;				 /* set the ply level */
} /* MenuSetPly */


/****************************************************************
*
* HandleMenu - Handle a menu event
*
* Input:
*      menuNum - menu number of menu to handle
*
****************************************************************/
void HandleMenu (int menuNum)
{
switch (menuNum) {					   /* handle the menu */
   case apple_AboutReversi:
       MenuAbout ();
       break;

   case file_NewGame:
       NewGame ();
       DrawBoard ();
       break;

   case file_Quit:
       done = true;
       break;

   case level_1Ply: case level_2Ply: case level_3Ply: case level_4Ply:
   case level_5Ply: case level_6Ply: case level_7Ply: case level_8Ply:
       MenuSetPly (menuNum);
       break;

   case options_SelfPlay:
       MenuSelfPlay ();
       break;

   case options_ComputerPlaysWhite:
       MenuColor ();
       break;

   case options_Pass:
       MenuPass ();
       break;

   case options_ShowScoreWindow:
       MenuShowScoreWindow ();
       break;

   case options_ShowMovesWindow:
       MenuShowMovesWindow ();
       break;

   default:
       break;
   } /* switch */

HiliteMenu (false, (int) (lastEvent.wmTaskData >> 16));
} /* HandleMenu */


/****************************************************************
*
* HideAWindow - Hide the front window
*
****************************************************************/
void HideAWindow (void)
{
if (FrontWindow () == scoreWindow)
   MenuShowScoreWindow ();
else /* if FrontWindow == movesWindow */
   MenuShowMovesWindow ();
} /* HideAWindow */


/****************************************************************
*
* LegalMove - Check if a move is legal
*
* Input:
*      index - move to make
*      color - color of player making the move
*
****************************************************************/
BOOL LegalMove (int index, int color)
{
struct moveListType moveList;			   /* for list of legal moves */
int i;						   /* loop variable	      */

GetMoves (board, color, &moveList);
for (i = 0; i < moveList.num; i++)
   if (index == moveList.moves[i])
       return true;
return false;
} /* LegalMove */


/****************************************************************
*
* GrowMoves - Grow the Moves window (the only window that can grow)
*
****************************************************************/
void GrowMoves (void)
{
Rect rt; 			      /* for creating scroll bar 	      */
int  movesInWindow;		      /* # moves the Moves window can display */
union longShort { long isLong;	      /* for converting between int and long  */
		  int  lsw, msw; } r, s;

s.isLong = GetMaxGrow (movesWindow);			      /* get max size */
					   /* track the growing of the window */
r.isLong = GrowWindow (s.msw, 64, lastEvent.where.h, lastEvent.where.v,
		     movesWindow);
if (r.isLong) {					 /* if the size changed then... */
   SizeWindow (s.msw, r.lsw, movesWindow);	  /* change the window's size */
   MoveControl (73, r.lsw - 12, growHandle);	  /* move the grow box	      */
   DisposeControl (vScrollHandle);		  /* resize the scroll bar    */
   rt.h1 = 73;	   rt.h2 = 89;
   rt.v1 = 0;	   rt.v2 = r.lsw - 11;

   vScrollHandle =				  /* update the thumb size    */
      NewControl (movesWindow, &rt, NULL, 3, 0, 112, 25, (void *) 0x06000000,
		  0L, NULL);
					  /* position thumb of the scroll bar */
   SetCtlParams (Even (movesMade) / 2 * charHeight, r.lsw - 25, vScrollHandle);
   SetCtlValue (topMove / 2 * charHeight, vScrollHandle);

   if (r.lsw > moveHeight) {			/* if the window grew then... */
						/* dispose of trailing blanks */
       movesInWindow = (r.lsw - 25) / charHeight * 2 + 2;
       if ((Even(topMove) + movesInWindow + 1) / 2 > (Even (movesMade) + 1) / 2)
	 {
	   topMove = Even (movesMade) - movesInWindow;
	   if (!(topMove & 0x0001))
	       topMove++;
	   if (topMove < 1)
	       topMove = 1;
	   }

       updateMoves = true;				 /* redraw moves list */
       moveHeight  = r.lsw;
       DrawMoves ();
       }

   moveHeight = r.lsw;				    /* update the window size */
   }
} /* GrowMoves */


/****************************************************************
*
* Scroll - Handle vertical scrolls in the Moves window
*
****************************************************************/
void Scroll (void)
{
int part;			      /* part # from TrackControl	      */
int movesInWindow;		      /* # moves the Moves window can display */

part = TrackControl (lastEvent.where.h, lastEvent.where.v, (void *) -1,
		     vScrollHandle);
movesInWindow = (moveHeight - 25) / charHeight * 2 + 2;

if ((part > 4) && (part < 9)) {	    /* if the part is not the slide switch... */
   switch (part) {
       case 5:						   /* handle up arrow */
	   if (topMove > 1)
	       topMove -= 2;
	   break;

       case 6:						 /* handle down arrow */
	   if (Even (topMove) + movesInWindow < Even (movesMade) + 1)
	       topMove += 2;
	   break;

       case 7:						    /* handle up page */
	   if (topMove > 1) {
	       topMove -= movesInWindow;
	       if (topMove < 1)
		   topMove = 1;
	     }
	   break;

       case 8:						  /* handle down page */
	   if (Even(topMove) + movesInWindow < Even(movesMade) + 1) {
	       topMove += movesInWindow;
	       if ( ((Even(topMove) + movesInWindow + 1) / 2)  >
		    (Even(movesMade) + 1) / 2 ) {
		   topMove = Even (movesMade) - movesInWindow;
		   if (! (topMove >> 16) & 0x0001)
		       topMove++;
		   }
	       }
       } /* switch */

   updateMoves = true;					 /* redraw the window */
   DrawMoves ();
					  /* position thumb of the scroll bar */
   SetCtlValue (topMove / 2 * charHeight, vScrollHandle);
   }

else if (part == 129) {			/* reposition based on new thumb loc. */
   topMove = GetCtlValue (vScrollHandle) * 2 / charHeight +1;
   if (! (topMove >> 16) & 0x0001)
       topMove++;
   updateMoves = true;
   DrawMoves ();
   }
} /* Scroll */


/****************************************************************
*
* TryMove - If there is a legal move at the indicated coordinates,
*	    make it
*
****************************************************************/
void TryMove (void)
{
Point p; 					    /* location of mouse      */
int   row, col;					    /* position on board      */
int   index;					    /* index into board array */

if (movesLeft) { 			       /* make sure game is not over  */
   StartDrawing (boardWindow);		       /* easy way to set port	      */
   p.h = lastEvent.where.h;		       /* find out where the mouse is */
   p.v = lastEvent.where.v;
   GlobalToLocal (&p);
   col = p.h / squareWidth + 1;			 /* convert to board index    */
   row = p.v / squareHeight + 1;
   index = row * 10 + col;

   if (LegalMove( index, currentColor)) {	 /* if move is legal, make it */
       MakeAMove (index, currentColor);
       currentColor ^= 3;			      /* switch color to move */
       }

   else {					      /* flag a bad move      */
       strcpy (msg, "\pIllegal move -\rtry again.");
       DoAlert (stop, msg);
       }
   CheckForDone ();
   DrawScore (); 				      /* update the score     */
   DrawMoves (); 				      /* update the move list */
   }
} /* TryMove */


/****************************************************************
*
* DoContent - Handle a mouse-down event in the content region
*
****************************************************************/
void DoContent (void)
{
int part;				    /* part # returned by FindControl */
CtlRecHndl ctl;				    /* control handle		      */

if (FrontWindow () == (GrafPortPtr) lastEvent.wmTaskData) {
   if ((GrafPortPtr) lastEvent.wmTaskData == boardWindow)
       TryMove ();					 /* try making a move */

   else if ((GrafPortPtr) lastEvent.wmTaskData == movesWindow) {
       part = FindControl (&ctl, lastEvent.where.h, lastEvent.where.v,
			  movesWindow);
       if (part == 10)
	   GrowMoves (); 				 /* handle grow box   */
       else if (part)
	   Scroll ();					 /* handle scroll bar */
       }
   }
} /* DoContent */


/****************************************************************
*
* Update - Handle an update event
*
****************************************************************/
void Update (void)
{
if (lastEvent.message == (long) boardWindow) {
   BeginUpdate (boardWindow);			   /* update the board window */
   DrawBoard (); 				   /* redraw the board	      */
   EndUpdate (boardWindow);			   /* complete the update     */
   }

else if (lastEvent.message == (long) scoreWindow) {
   BeginUpdate (scoreWindow);			   /* update the score window */
   DrawScore (); 				   /* redraw the score window */
   EndUpdate (scoreWindow);			   /* complete the update     */
   }

else if (lastEvent.message == (long) movesWindow) {
   BeginUpdate (movesWindow);			   /* update the Moves window */
   updateMoves = true;				   /* redraw the Moves window */
   DrawMoves ();
   EndUpdate (movesWindow);			   /* complete the update     */
   DrawControls (movesWindow);			   /* redraw the controls     */
   }
} /* Update */


/****************************************************************
*
* Main program starts here
*
****************************************************************/

int main (void)

{
startdesk (640); 			/* initialize the dekstop environment */
QDAuxStartUp ();
SetPenMode (0);				     /* set pen mode to copy	      */
InitMenus ();				     /* set up the menu bar	      */
InitWindow ();				     /* draw the board's window       */
InitVariables ();			     /* initialize global variables   */
lastEvent.wmTaskMask = 0x13FFL;		     /* let Task Master do most stuff */
ShowCursor ();				     /* show the cursor		      */

done = false;						   /* main event loop */
do {
   event = TaskMaster (0x074E, &lastEvent);
   switch (event) {			      /* handle the events we need to */
       case wInMenuBar: HandleMenu ((int) lastEvent.wmTaskData);
			break;

       case inUpdate:	Update ();
			break;

       case wInContent: DoContent ();
			break;

       case wInGoAway : HideAWindow ();
			break;

       default:		break;
       }


   /* If the Moves window has been brought to front, draw its controls. */

   if (FrontWindow () == movesWindow) {
       if (movesNotFront) {
	   movesNotFront = false;
	   HiliteControl (0, vScrollHandle);
	   HiliteControl (0, growHandle);
	   DrawControls (movesWindow);
	   }
       }
   else if (! movesNotFront) {
       movesNotFront = true;
       HiliteControl (255, vScrollHandle);
       HiliteControl (255, growHandle);
       }

   if (movesLeft) {				     /* let the computer move */
       if (selfPlay) {
	   FindMove (currentColor);
	   currentColor ^= 3;
	   DrawScore ();
	   DrawMoves ();
	   }
       else if (color == currentColor) {
	   FindMove (color);
	   currentColor ^= 3;
	   DrawScore ();
	   DrawMoves ();
	   }
       } /* if */
   }
while (!done);

QDAuxShutDown ();			/* shut down the desktop environment */
enddesk ();
} /* Reversi */
