/****************************************************************
*
*  Echo
*
*  This is about the simplest a classic desk accessory can be,
*  providing a quick framework for developing your own.  It
*  simply reads strings typed from the keyboard and echos
*  them back to the screen.
*
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************/

#pragma keep "Echo"
#pragma cda "Echo from C" Start ShutDown
#pragma lint -1

#include <stdio.h>
#include <string.h>

char str[256];


void Start(void)

{
printf("This program echoes the strings you type from the keyboard.  To\n");
printf("quit, hit the RETURN key at the beginning of a line.\n\n");

do {
   fgets(str, 256, stdin);		/* read a string */
   printf("%s\n", str);			/* write the same string */
   }
while (strlen(str) > 1);		/* quit if the string is empty */
}


void ShutDown(void)

{
}
