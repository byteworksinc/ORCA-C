/***************************************************************
*
*  Command Line
*
*  On the Apple IIgs, all EXE programs can expect three things
*  to be passed to them by the shell: a user ID number for use
*  with tool kits, an eight character shell ID which
*  identifies the shell that executed the program, and the
*  text from the command line itself.  This program shows how
*  to access these values from C, printing them to the
*  screen.  Be sure and execute the program with some text
*  after the name - for example,
*
*       CLINE Hello, world.
*
*  When any EXE program returns to the shell, it passes an
*  error code in the A register.  You can set this value from
*  C by returning an integer value as the result of main, as
*  shown in this program.
*
*  If you compile this program from the desktop, turn debug
*  code off before executing the program from the shell window.
*
***************************************************************/

#pragma keep "CLine"
#pragma lint -1

#include <stdio.h>
#include <orca.h>

int main(void)

{
char *shellName, *line;
int userNumber;

userNumber = userid();
shellName = shellid();
line = commandline();
printf("User ID: %d\n", userNumber);
printf("Shell ID: %s\n", shellName);
printf("Command line: %s\n", line);
return 0;
}
