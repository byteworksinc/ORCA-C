/*****************************************************************
*
*   Keyboard Handling
*
*   This program shows one way to access the keyboard directly
*   from ORCA/C.  Keep in mind that the standard file input
*   collects an entire line of characters before reporting the
*   first character.  This is necessary to allow editing of the
*   input line.  When using the desktop environment, you can get
*   keypress events from the event manager.  This program shows
*   how to detect a keypress as soon as it is hit.  It echoes
*   keys until you type CONTROL-@ (ASCII 0).
*
*   The program works by reading the keyboard (at $C000) until
*   the value is negative, indicating that a key has been
*   pressed.  It then stores a value (any value will do) in
*   $C010 to indicate that the key has been read.  This makes
*   the value at $C010 positive (bit 7 is clear).  The value of
*   the key is then ANDed with $7F to clear the high bit.
*
*   THIS METHOD OF READING THE KEYBOARD ONLY WORKS IN THE TEXT
*   ENVIRONMENT.  When the event manager is active, as it always
*   is in a desktop program, you should call the event manager
*   to read keystrokes.
*
*   Checking to see when a key has been pressed is bundled into
*   the function KeyPress.  Returning the key and clearing the
*   strobe is done in ReadChar.
*
*   See key2 for a version that splits the keyboard routines off
*   into a separately compilable module.
*
*   See key3 for a version that uses assembly language to do the
*   same thing.
*
*   By Mike Westerfield and Barbara Allred
*
*   Copyright 1987-1989
*   Byte Works, Inc.
*
*******************************************************************/

#pragma keep "Key"
#pragma lint -1

#include <stdio.h>

static char ch;                               /* character read from keyboard */

/****************************************************************
*
* KeyPress - Check if a key has been pressed
*
****************************************************************/

int KeyPress(void)

{
char *keyboard;

keyboard = (char *) 0x00C000;
return ((*keyboard) & 0x80) != 0;
}


/****************************************************************
*
* ReadChar - Return the last character typed on the keyboard.
*            Note:  Returns a character whether or not one has
*                   been typed!
*
****************************************************************/

char ReadChar (void)

{
char *keyboard, *strobe;

keyboard = (char *) 0x00C000;
strobe = (char *) 0x00C010;
*strobe = 0;
return *keyboard & 0x7F;
}


/****************************************************************
*
* Main program starts here
*
****************************************************************/

int main(void)

{
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
