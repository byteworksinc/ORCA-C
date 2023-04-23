/*****************************************************************
*
*   Keyboard Handling
*
*   This program demonstrates separate compilation by splitting
*   the program KEY into two parts: the main program, and a
*   separately compiled file with the keyboard subroutines that
*   can then be called from many different programs without the
*   need for recompiling.  See KEY.CC for a full description of
*   what this program does.
*
*   The program now consists of four files:
*
*        Key2.Build - EXEC file which separately compiles the two
*                     source files, then links their object
*                     modules to create the final program.  To
*                     use the EXEC file, simply type KEY2.BUILD
*                     from the command line.
*
*        Key2.cc    - File containing main program.
*
*        Key2.h     - Header file accessed by the main program;
*                     Contains declarations of external functions.
*
*        Key2.Funcs - File containing keyboard functions called
*                     by main program.
*
*   See Key3 for a version that uses assembly language to read
*   the keyboard.
*
*   By Mike Westerfield and Barbara Allred
*
*   Copyright 1987-1989
*   Byte Works, Inc.
*
*******************************************************************/

#pragma keep "Key2"
#pragma lint -1

#include "Key2.h"
#include <stdio.h>

int main(void)

{
char ch;

printf ("Press any key(s) and then RETURN.  Enter CTRL-@ to quit.\n");
do {
   while (! KeyPress())			/* wait for a keypress */
      ;
   ch = ReadChar();			/* get character typed from keybrd */
   if (ch == 0x0D)			/* write character to the screen */
      printf ("\n");
   else
      printf ("%c", ch);
   }
while (ch != 0);
return 0;
}
