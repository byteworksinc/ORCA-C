/*****************************************************************
*
*  Text Printer Demo
*
*  This example shows how to access the .PRINTER text printer
*  driver from a C program.  The .PRINTER driver must be installed
*  before this sample is executed.
*
*  There really isn't much to this sample, which may seem bad at
*  first, but it's really good:  accessing the text printer driver
*  really is as simple as opening the printer and writing to it!
*
*  By Mike Westerfield
*
*  Copyright 1993
*  Byte Works, Inc.
*                                 
*****************************************************************/

#pragma keep "Print"
#pragma lint -1

#include <stdio.h>

void main (void)

{
FILE *f;

f = fopen(".printer", "w+");
fprintf(f, "Hello, printer!\n");
fputc('\f', f);			/* on most printers, this will eject a page */
fclose(f);
}
