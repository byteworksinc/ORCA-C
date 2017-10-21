/* Second file comprising Special Conformance Test 25.0.2 */

#pragma    memorymodel     1
#define    SIZE    3

char ch0 [3];                              /* global integers */
int  i0  [3];
                                           /* global functions */

/*****************************************************************************/

char * Init_Ch (void)
  {
   asm
     {
               lda     #'c'        /* init starting value for array */
               sep     #0x20        /* set the accumulator to 8 bits */
               ldx     #SIZE
       Top:    dex                 ; loop to initialize uch0 array
               bmi     Out
               sta     ch0,X
               inc     A
               bra     Top
       Out:    rep     #0x20        /* reset accumulator to 16 bits */
     }
   return (ch0);
  }


/*****************************************************************************/

int  * Init_Int  (int   i [])
  {
   int  j, *iptr = i;

   asm
     {
               lda     #10         /* init starting value for array */
               sta     j
               ldx     #SIZE
               ldy     #0
       Top:    sta     [iptr],Y    ; loop to initialize i array
               lda     j
               clc
               adc     #10
               sta     j
               iny
               iny
               dex
               bne     Top
     }
   return (iptr);
  }
