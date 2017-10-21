/*****************************************************************************/
/*                                                                           */
/* Special Conformance Test 4.3.0.1:  Ensure static variables and functions  */
/*                                    are not passed to the linker, and that */
/*                                    extern variables and functions are     */
/*                                    passed to the linker                   */
/*                                                                           */
/* Other files needed:  spc4301.h  - header file for separate compilation    */
/*                      spc4301.1.cc - separately compiled file              */
/*                      spc4301.2.cc - separately compiled file              */
/*                      spc4301.exec - controls compilation and linking      */
/*                      {workDisk}/spc4301.symt - linker's global symbol     */
/*                                                table for spc4.3.0.1.cc    */
/*                                                                           */
/* Special instructions:  Use the EXEC file spc4301.exec to separately       */
/*                        compile and link the three files.  A symbol table  */
/*                        is produced in the output file {workDisk}/         */
/*                        spc4301.symt.  The tester should use the linker's  */
/*                        symbol table to verify that only the extern        */
/*                        functions and variables are in the global symbol   */
/*                        table.  In addition, the EXEC file will try to     */
/*                        execute the program.  If all is well, a Pass/Fail  */
/*                        message will be written to standard out.           */
/*                                                                           */
/* The global functions are:   ChangeChar, L0                                */
/* The global variables are:   real, i, longNum                              */
/*                                                                           */
/*****************************************************************************/

#include <math.h>
#include "spc4301.h"

main ()
  {
   int count = 0;

   static extended E1 (double x, float y);
   static char ch;
   char *chPtr;

   extern int i;
   extern long L0 (int *j);

   count++;
   i = 0;
   while (chArray [i] != '\0')
     {
       ChangeChar (&chArray [i]);
       ++i;
     }
   chPtr = chArray;
   if ((strcmp (chPtr, "bcde")) != 0)
       goto Fail;

   count++;
   real = E1 (2.1, 1.5);
   if ( (fabs (real - 3.15)) > 0.1 )
       goto Fail;

   count++;
   ch = F1 (2.3, 'a');
   if (ch != 'c')
       goto Fail;

   count++;
   longNum = L0 ((int *) chArray);
   if (longNum != 25442)
       goto Fail;

   printf ("Passed Special Conformance Test spc4.3.0.1\n");
   return 0;

Fail:
   printf ("Failed Special Conformance Test spc4.3.0.1: count = %d\n", count);
   return 0;
  }

/*****************************************************************************/

static extended E1 (double x, float y)
  {
   return (x * y);
  }

/*****************************************************************************/

static int F1 (float a, char ch)
  {
   return ((long) a) + ((long) ch);
  }
