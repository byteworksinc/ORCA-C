/* Second file comprising Special Conformance Test 25.0.1 */

#define    SIZE    3

char ch0 [3];                              /* global integers */
int  i0  [3];
long L0  [3];
unsigned char uch0 [3];
unsigned int  ui0  [3];
unsigned long ul0  [3];
                                           /* global functions */

/*****************************************************************************/

char * Init_Ch   (char ch [])
  {
   char * chPtr = ch;

   asm
     {
               lda     #<'c'       /* init starting value for array */
               sep     #0x20        /* set the accumulator to 8 bits */
               ldy     #SIZE
       Top:    dey                 ; loop to initialize ch array
               bmi     Out
               sta     [chPtr],Y
               inc     A
               bra     Top
       Out:    rep     #0x20        /* reset accumulator to 16 bits */
     }
   return chPtr;
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


/*****************************************************************************/

long * Init_Long (long  L [])
  {
   int  j;

   for (j = 0; j < SIZE; j++)
       L [j] = j * 100;
   return (L);
  }


/*****************************************************************************/

unsigned char * Init_UCh (void)
  {
   asm
     {
               lda     #<'p'       /* init starting value for array */
               sep     #0x20        /* set the accumulator to 8 bits */
               ldx     #SIZE
       Top:    dex                 ; loop to initialize uch0 array
               bmi     Out
               sta     uch0,X
               inc     A
               bra     Top
       Out:    rep     #0x20        /* reset accumulator to 16 bits */
     }
   return (uch0);
  }


/*****************************************************************************/

unsigned int  * Init_UI  (unsigned int  ui [])
  {
   int  j;

   for (j = 0; j < SIZE; j++)
       ui [j] = (unsigned int) (j << 4);
   return (ui);
  }


/*****************************************************************************/

unsigned long * Init_UL  (unsigned long ul [])
  {
   int  j;

   for (j = 0; j < SIZE; j++)
       ul [j] = (unsigned long) (j + 0x777);
   return (ul);
  }
