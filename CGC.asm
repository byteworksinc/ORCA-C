	mcopy	cgc.macros
****************************************************************
*
*  CnvSX - Convert floating point to SANE extended
*
*  Inputs:
*        rec - pointer to a record
*
****************************************************************
*
CnvSX    start
rec      equ   4                        record containing values
rec_real equ   0                        disp to real value
rec_ext  equ   8                        disp to extended (SANE) value

         tsc                            set up DP
         phd
         tcd
         ph4   rec                      push addr of real number
         clc                            push addr of SANE number
         lda   rec
         adc   #rec_ext
         tax
         lda   rec+2
         adc   #0
         pha
         phx
         fd2x                           convert TOS to extended
         move4 0,4                      return
         pld
         pla
         pla
         rtl
         end

****************************************************************
*
*  CnvSC - Convert floating point to SANE comp
*
*  Inputs:
*        rec - pointer to a record
*
****************************************************************
*
CnvSC    start
rec      equ   4                        record containing values
rec_real equ   0                        disp to real value
rec_ext  equ   8                        disp to extended (SANE) value
rec_cmp  equ   18                       disp to comp (SANE) value

         tsc                            set up DP
         phd
         tcd
         ph4   rec                      push addr of real number
         clc                            push addr of SANE number
         lda   rec
         adc   #rec_ext
         tax
         lda   rec+2
         adc   #0
         pha
         phx
         fd2x                           convert TOS to extended
         clc                            push addr of SANE number
         lda   rec
         adc   #rec_ext
         tax
         lda   rec+2
         adc   #0
         pha
         phx
         clc                            push addr of COMP number
         lda   rec
         adc   #rec_cmp
         tax
         lda   rec+2
         adc   #0
         pha
         phx
         fx2c                           convert TOS to extended
         move4 0,4                      return
         pld
         pla
         pla
         rtl
         end

****************************************************************
*
*  InitLabels - initialize the labels array
*
*  Outputs:
*        labelTab - initialized
*        intLabel - initialized
*
****************************************************************
*
InitLabels start
maxLabel equ   2400

!                                       with labelTab[0] do begin
         lda   #-1                         val := -1;
         sta   labelTab+6
         sta   labelTab+8
         stz   labelTab                    defined := false;
         stz   labelTab+2                  chain := nil;
         stz   labelTab+4
!                                          end; {with}
         ldx   #labelTab                for i := 1 to maxLabel do
         ldy   #labelTab+10                labelTab[i] := labelTab[0];
         lda   #maxLabel*10-1
         mvn   labelTab,labelTab
         stz   intLabel                 intLabel := 0;
         rtl
         end
