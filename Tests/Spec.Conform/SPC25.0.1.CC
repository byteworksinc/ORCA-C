/* Special Conformance Test 25.0.1:  Verification of mini-assembler exprs.    */
/*                                                                            */
/* Other files needed: spc25.1.exec  -   EXEC file which separately compiles, */
/*                                       links, and executes the two files    */
/*                                       comprising this test                 */
/*                     spc25.1.1.cc  -   Separately compiled file which       */
/*                                       contains global data and routines    */
/*                                       accessed by the main program         */
/*                     spc25.1.h     -   Header file containing global        */
/*                                       declarations for second source file  */

#include   <stdio.h>
#include   "spc25.1.h"

static int i1  = 33;

main ()
  {
   int   count = 0, i;
   char  *chPtr;
   int   *iPtr;
   long  *lPtr;
   unsigned char  *uchPtr;
   unsigned int   *uiPtr;
   unsigned long  *ulPtr;


   /* Call routines to initialize global arrays.  Verify initialization. */

   count++;
   chPtr = Init_Ch (ch0);
   if ((*chPtr != 'e') || (chPtr [1] != 'd') || (chPtr [2] != 'c'))
       goto Fail;

   count++;
   iPtr = Init_Int (i0);
   if ((*iPtr != 10) || (iPtr [1] != 20) || (iPtr [2] != 30))
       goto Fail;

   count++;
   lPtr = Init_Long (L0);
   if ((*lPtr != 0) || (lPtr [1] != 100) || (lPtr [2] != 200))
       goto Fail;

   count++;
   uchPtr = Init_UCh ();
   if ((*uchPtr != 'r') || (uchPtr [1] != 'q') || (uchPtr [2] != 'p'))
       goto Fail;

   count++;
   uiPtr = Init_UI (ui0);
   if ((*uiPtr != 0) || (uiPtr [1] != 16) || (uiPtr [2] != 32))
       goto Fail;

   count++;
   ulPtr = Init_UL (ul0);
   if ((*ulPtr != 0x777) || (ulPtr [1] != 0x778) || (ulPtr [2] != 0x779))
       goto Fail;

   asm
     {
               bra     Test

       uch1:   dcb     't'

       /* Test expressions */

       Test:   lda     i1
               sta     i
               cmp     #33
               bne     Err

               lda     uch1
               and     #0x00FF
               sta     i
               cmp     #0x0074
               bne     Err

               lda     [iPtr]
               cmp     #10
               beq     Out
       Err:    inc     count
               jmp     Fail
     }

Out:
   printf ("Passed Conformance Test 25.0.1\n");
   return;

Fail:
   printf ("count = %d  i = %d\n", count, i);
   printf ("Failed Conformance Test 25.0.1\n");
  }
