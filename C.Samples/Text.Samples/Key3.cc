/*****************************************************************
*
*   Keyboard Handling
*
*   This is the final incarnation of the keyboard polling sample.
*   See KEY.CC for complete comments on what the program does and
*   how it works.
*
*   In this version, we will write the two subroutines in
*   assembly language.  While you could use separate compilation
*   to compile and assemble the two pieces separately, then
*   link them, as in the last example, we will use chaining
*   to avoid all of that.  Chaining is a feature of all
*   languages fully installed in ORCA or APW that allows a
*   single program to be written in more than one language
*   without resorting to separate compilation.  Which method
*   you prefer - chaining or separate compilation - depends
*   on your own taste.
*
*   To chain the two files together, we just place an append
*   command after the end of the program.  The rest is automatic
*   To compile, assemble, link, and execute, we can now use the
*   familiar RUN command:
*
*        run key3.cc
*
*   Note: both the assembler and compiler must be properly
*   installed for this to work.  The assembler is sold
*   separately as ORCA/M 2.0 for the Apple IIGS.
*
*   By Mike Westerfield and Barbara Allred
*
*   Copyright 1987-1989
*   Byte Works, Inc.
*
*******************************************************************/

#pragma keep "Key3"
#pragma lint -1

#include <stdio.h>

int main (void)

{
extern int KEYPRESS (void);		/* declare assembly-language    */
extern int READCHAR (void);		/*   routines to be called      */
char ch;				/* character read from keyboard */

printf("Press any key(s) and then RETURN.  Enter CTRL-@ to quit.\n");
do {
   while (! KEYPRESS())			/* wait for a keypress */
      ;
   ch = READCHAR();			/* get character typed from keybrd */
   if (ch == 0x0D)			/* write character to the screen */
      printf ("\n");
   else
      printf ("%c", ch);
   }
while (ch != 0);
return 0;
}

#append "Key3.asm"
