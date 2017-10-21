/* Special Conformance Test 25.0.2:  Verification of long addressing in mini- */
/*                                   assembler when using large memory model  */
/*                                                                            */
/* Other files needed: spc25.2.exec  -   EXEC file which separately compiles, */
/*                                       links, and executes the two files    */
/*                                       comprising this test                 */
/*                     spc25.2.1.cc  -   Separately compiled file which       */
/*                                       contains global data and routines    */
/*                                       accessed by the main program         */

#pragma    memorymodel     1
#include   <stdio.h>

static int i1  = 33;

extern char ch0 [];
extern int  i0  [];

extern char * Init_Ch  (void);
extern int  * Init_Int (int i []);


main ()
  {
   char  *chPtr;
   int   *iPtr;
   int   count = 0;

   /* Call routines to initialize global arrays.  Verify initialization. */

   count++;
   chPtr = Init_Ch ();
   if ((*chPtr != 'e') || (chPtr [1] != 'd') || (chPtr [2] != 'c'))
       goto Fail;

   count++;
   iPtr = Init_Int (i0);
   if ((*iPtr != 10) || (iPtr [1] != 20) || (iPtr [2] != 30))
       goto Fail;

   asm
     {
               bra     Test

       uch1:   dcb     't'

       /* Test expressions */

       Test:   lda     i1
               cmp     #33
               bne     Err

               lda     uch1
               and     #0x00FF
               cmp     #0x0074
               bne     Err

               lda     [iPtr]
               cmp     #10
               beq     Out
       Err:    inc     count
               jmp     Fail
     }

Out:
   printf ("Passed Conformance Test 25.0.2\n");
   return;

Fail:
   printf ("count = %d\n", count);
   printf ("Failed Conformance Test 25.0.2\n");
  }
