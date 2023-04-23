****************************************************************
*
*  KeyPress - Check to see if a key has been pressed
*
*  Outputs:
*        A - 1 (true) if pressed, else 0
*
****************************************************************
*
KeyPress start
keyBoard equ   $C000                    keyboard location

         sep   #$30                     use short regs for load
         lda   >keyBoard                load keyboard value
         asl   A                        shift sign bit into bit 0
         rol   A
         rep   #$30                     back to long regs
         and   #1                       and out all but the bit we want
         rtl
         end

****************************************************************
*
*  ReadChar - return the last character typed on the keyboard
*
*  Outputs:
*        A - character typed
*
****************************************************************
*
ReadChar start
keyBoard equ   $C000                    keyboard location
strobe   equ   $C010                    strobe location

         sep   #$30                     use short regs
         sta   >strobe                  clear strobe
         lda   >keyBoard                load character
         rep   #$30                     back to long regs
         and   #$007F                   and out high bits
         rtl
         end
