         mcopy cgc.macros
****************************************************************
*
*  CnvSX - Convert floating point to SANE extended
*
*  Inputs:
*        rec - pointer to a record
*
****************************************************************
*
CnvSX    start cg
rec      equ   4                        record containing values
rec_real equ   0                        disp to real (extended) value
rec_ext  equ   10                       disp to extended (SANE) value

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
         fx2x                           convert TOS to extended
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
CnvSC    start cg
rec      equ   4                        record containing values
rec_real equ   0                        disp to real (extended) value
rec_ext  equ   10                       disp to extended (SANE) value
rec_cmp  equ   20                       disp to comp (SANE) value

         tsc                            set up DP
         phd
         tcd
         ph4   rec                      push addr of real number
         clc                            push addr of SANE comp number
         lda   rec
         adc   #rec_cmp
         tax
         lda   rec+2
         adc   #0
         pha
         phx
         fx2c                           convert TOS to SANE comp number
         move4 0,4                      return
         pld
         pla
         pla
         rtl
         end

****************************************************************
*
*  procedure CnvXLL (var result: longlong; val: extended);
*
*  Convert floating point to long long
*
*  Inputs:
*        result - longlong to hold the converted value
*        val - the real value
*
****************************************************************

CnvXLL   start cg

         subroutine (4:result,10:val),0

         pei   (val+8)
         pei   (val+6)
         pei   (val+4)
         pei   (val+2)
         pei   (val)   
         jsl   ~CnvRealLongLong
         pl8   [result]
         
         return
         end

****************************************************************
*
*  procedure CnvXULL (var result: longlong; val: extended);
*
*  Convert floating point to unsigned long long
*
*  Inputs:
*        result - longlong to hold the converted value
*        val - the real value
*
****************************************************************

CnvXULL  start cg

         subroutine (4:result,10:val),0

         pei   (val+8)
         pei   (val+6)
         pei   (val+4)
         pei   (val+2)
         pei   (val)   
         jsl   ~CnvRealULongLong
         pl8   [result]
         
         return
         end

****************************************************************
*
*  function CnvLLX (val: longlong): extended;
*
*  convert a long long to a real number
*
*  Inputs:
*        val - the long long value
*
****************************************************************

CnvLLX   start cg

         subroutine (4:val),0

         ph8   [val]
         jsl   ~CnvLongLongReal
         pla
         sta   >rval
         pla
         sta   >rval+2
         pla
         sta   >rval+4
         pla
         sta   >rval+6
         pla
         sta   >rval+8
         
         lla   val,rval
         return 4:val

rval     ds    10
         end

****************************************************************
*
*  function CnvULLX (val: longlong): extended;
*
*  convert an unsigned long long to a real number
*
*  Inputs:
*        val - the unsigned long long value
*
****************************************************************

CnvULLX  start cg

         subroutine (4:val),0

         ph8   [val]
         jsl   ~CnvULongLongReal
         pla
         sta   >rval
         pla
         sta   >rval+2
         pla
         sta   >rval+4
         pla
         sta   >rval+6
         pla
         sta   >rval+8
         
         lla   val,rval
         return 4:val

rval     ds    10
         end

         datachk off
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
InitLabels start cg
maxLabel equ   3200

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
