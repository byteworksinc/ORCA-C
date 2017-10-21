/* Special Conformance Test 3.6.0.1:  Test explicit line numbering (#line) */

#pragma debug 9                /* enable range checking and trace back */

void Sub (void)
  {
   int a [4080];               /* ensure stack overflow into SANE's area */
  }

#line 9999                     /* expect trace back to report error on line  */
                               /*    9999+4 (call to Sub)                    */
main ()
  {
   Sub ();
  }
