/* Special Conformance Test 3.6.0.2:  Test explicit line numbering (#line) */
/*                                    with a filename                      */

#define  lineNum(x)    x

#pragma debug 9                /* enable range checking and trace back */

void Sub (void)
  {
   int a [4080];               /* ensure stack overflow into SANE's area */
  }

#line lineNum(88) "noFile"     /* expect trace back to report error on line  */
                               /*   91 (call to Sub), in file noFile         */
Sub2()
{
Sub();
}

main ()
  {
   Sub2 ();
  }
