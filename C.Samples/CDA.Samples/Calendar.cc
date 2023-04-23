/***************************************************************
*
*  Calendar
*
*  This classic desk accessory shows the calendar for the
*  current date.  The arrow keys can be used to see calendars
*  for previous or future months.
*
*  Commands (each is a single keystroke)
*
*       up-arrow        Look at the same month in the previous
*                       year.
*       down-arrow      Look at the same month in the next
*                       year.
*       left-arrow      Look at the previous month.
*       right-arrow     Look at the next month.
*       ? or /          Display help screen.
*       ESC             Return to CDA main menu.
*
*  Mike Westerfield
*
*  Copyright 1987-1989
*  Byte Works, Inc.
*
***************************************************************/

#pragma keep "Calendar"
#pragma cda "Calendar" Start ShutDown
#pragma lint -1

#include <stddef.h>
#include <stdio.h>
#include <time.h>
#include <misctool.h>

#define LEFT_ARROW	0x08		/* key codes for legal commands */
#define DOWN_ARROW	0x0A
#define UP_ARROW	0x0B
#define RIGHT_ARROW	0x15
#define ESC		0x1B
#define SLASH		'/'
#define QUESTION	'?'

int ch;					/* ord of last character read */
int month, year;			/* current month and year */

/****************************************************************
*
*  Factor:  Computes the 'factor' for the first day of the
*           month.  The factor is the number of days since
*           31 Dec 0000.
*
****************************************************************/

long Factor (long year, long month)

{
if (month < 2)
    return 365 * year + 1 + 31 * month + (year - 1) / 4 -
              ((year - 1) / 100 + 1) * 3 / 4;
return 365 * year + 1 + 31 * month - ((month + 1) * 4 + 23) / 10 +
              year / 4 - (year / 100 + 1) * 3 / 4;
}

/****************************************************************
*
*  GetKey:  Returns the ordinal value of the next key typed
*           by the user.
*
****************************************************************/

int GetKey (void)

{
char ch, *cp;

cp = (char *) 0x00C000;			/* wait for keypress */
while ((*cp & 0x80) == 0) ;
ch = *cp;				/* save the key */
cp = (char *) 0x00C010;			/* clear the strobe */
*cp = 0;
return ch & 0x7F;			/* return the key read */
}

/****************************************************************
*
*  GetThisMonth:  Reads the clock to obtain today's month
*
****************************************************************/

void GetThisMonth (void)

{
time_t lt;				/* encoded time */
struct tm *ct;				/* current time */

lt = time(NULL);			/* get the coded time */
ct = gmtime(&lt);			/* convert to a decoded time */
year = ct->tm_year + 1900;		/* set the month/year */
month = ct->tm_mon;
}

/****************************************************************
*
*  GotoXY:  Positions the cursor
*
****************************************************************/

void GotoXY (int x, int y)

{
putchar(0x1E);
putchar(0x20 + x);
putchar(0x20 + y);
}

/****************************************************************
*
*  PrintCalendar:  Prints the calendar for the current
*                  and year.
*
****************************************************************/

void PrintCalendar (void)

{
#define TAB	26			/* disp of calendar from left edge */
#define VTAB	5			/* disp of calendar from top */

int startDay,				/* day of week for 1st day in month */
    numDays,				/* # days in the month */
    nextMonth, nextYear,		/* work variables */
    i,					/* loop variable */
    vt,					/* line # for next line of days */
    pos;				/* day position for next date */

/* Compute day of week for 1st day in month */
startDay = (int) ((Factor (year, month) - 1) % 7);
nextMonth = month+1;			/* compute # days in month */
if (nextMonth == 12) {
   nextMonth = 0;
   nextYear = year+1;
   }
else
   nextYear = year;
numDays = (int) (Factor (nextYear, nextMonth) - Factor (year, month));

putchar(12);				/* clear the screen */
GotoXY(TAB+7, VTAB);			/* position cursor */
switch (month) {			/* write the month */
   case 0:  printf(" January ");     break;
   case 1:  printf("February ");     break;
   case 2:  printf("  March ");      break;
   case 3:  printf("  April ");      break;
   case 4:  printf("   May ");       break;
   case 5:  printf("  June ");       break;
   case 6:  printf("  July ");       break;
   case 7:  printf(" August ");      break;
   case 8:  printf("September ");    break;
   case 9:  printf(" October ");     break;
   case 10: printf("November ");     break;
   case 11: printf("December ");
   }
printf("%d", year);			/* write the year */
GotoXY(TAB, VTAB+2);			/* write the day header line */
printf("Sun Mon Tue Wed Thu Fri Sat");
vt = VTAB+4;				/* set current date line */
pos = 0;				/* set day position */
GotoXY(TAB-1, vt);			/* position cursor for 1st line */
for (i = 1; i <= startDay; i++) {	/* skip over blank days */
   pos++;
   printf("    ");
   }

/* Write the dates */
for (i = 1; i <= numDays; i++) {
   printf("%4d", i);
   pos++;
   if (pos == 7) {
      pos = 0;
      vt += 2;
      GotoXY(TAB-1, vt);
      }
   }
GotoXY(25, 23);				/* write instructions */
printf("Hit ? for help,  or ESC to quit");
}

/****************************************************************
*
*  PrintHelp:  Print the help screen.
*
****************************************************************/

void PrintHelp (void)

{
int ch;					/* dummy variable for reading keyboard */

putchar(0x0C);				/* clear screen */
printf( "This program recognizes the following single-keystroke commands:"
        "\n\n"
        "     key             action\n"
        "     ---             ------\n"
        "     up-arrow        Show the current month in the previous year.\n"
        "     down-arrow      Show the current month in the next year.\n"
        "     left-arrow      Show the previous month.\n"
        "     right-arrow     Show the next month.\n"
        "     ESC             exit the program.");

GotoXY(0, 23);
printf("Hit any key to return to the program.");
ch = GetKey();
}

/**************************************************************
*
*  Start:  Body of calendar program
*
**************************************************************/

void Start(void)

{
putchar('\006');			/* turn the cursor off */
GetThisMonth();				/* find out what month it is */
PrintCalendar();			/* print the calendar for this month */
do {
   ch = GetKey();			/* get a command */
   switch (ch) {
      case LEFT_ARROW: {
         month--;
         if (month < 0) {
            month = 11;
            year--;
            }
         PrintCalendar();
         break;
         }

      case RIGHT_ARROW: {
         month++;
         if (month > 11) {
            month = 0;
            year++;
            }
         PrintCalendar();
         break;
         }

      case UP_ARROW: {
         year--;
         PrintCalendar();
         break;
         }

      case DOWN_ARROW: {
         year++;
         PrintCalendar();
         break;
         }

      case QUESTION:
      case SLASH: {
         PrintHelp();
         PrintCalendar();
         break;
         }

      case ESC: return;

      default:
         SysBeep();
      }
   }
while (1);
}

/*************************************************************
*
*  ShutDown: Does nothing
*
*************************************************************/

void ShutDown(void)

{
}
