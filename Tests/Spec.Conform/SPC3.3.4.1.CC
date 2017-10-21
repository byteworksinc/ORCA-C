/* Special Conformance Test 3.3.4.1:  Verification of __DATE__ and __TIME__ */
/*                                    predefined macros                     */
/*                                                                          */
/* The user should verify that the __DATE__ macro returns the computer's    */
/* current clock date, in the form:  Mmm dd yyyy.  The user should also     */
/* verify that the __TIME__ macro return the computer's current clock time  */
/* in the form:  hh:mm:ss.                                                  */

main ()
  {
   printf ("The current date is: '%s'\n", __DATE__);
   printf ("The current time is: '%s'\n", __TIME__);
  }
