/*                                                                        */
/* Special Conformance Test 13.2.0.1:  Verification of error handling     */
/*                                     facilities in the standard library */
/*                                                                        */
/* Tester needs to verify that an error message is written for each       */
/* invocation of strerror and perror.  She should also check that the     */
/* output from perror is in this form:  User's message, colon, blank, and */
/* then the standard error message.  Finally, the tester needs to ensure  */
/* that when errno is set to EDOM and ERANGE, the error message written   */
/* is appropriate.                                                        */
/*                                                                        */

#include <errno.h>
#include <stddef.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

main ()
  {
   int i;
   char ch [] = "Error message is";


   for (errno = 1; errno <= sys_nerr; errno++)
     {
       printf ("Errno = %d\n", errno);
       printf ("%s\n", strerror (errno));
       perror (ch);
     }

   errno = EDOM;
   printf ("Errno = %d\n", errno);
   printf ("%s\n", strerror (errno));
   perror (ch);

   errno = ERANGE;
   printf ("Errno = %d\n", errno);
   printf ("%s\n", strerror (errno));
   perror (ch);
  }
