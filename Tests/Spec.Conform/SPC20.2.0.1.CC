/* Special Conformance Test 20.2.0.1:  Verification of time, asctime, ctime, */
/*                                     localtime, gmtime, mktime, difftime   */
/*                                                                           */
/* The tester needs to verify that the printed time is accurate for the      */
/* current clock setting of machine.                                         */

#include <stddef.h>
#include <time.h>

main ()
  {
   time_t secondTime, theTime, *tptr = &theTime;
   char   *timeString;
   struct tm *TM;
   double d;


   theTime = time (tptr);             /* call time to get current date & time */
   if (theTime == -1)                 /*   represented as an integral type    */
       goto Fail;
   if (theTime != *tptr)
       goto Fail;


   /* Call ctime to get current date/time in the form:                        */
   /* Day Mon 99 99:99:99 yyyy\n\0   where Day = day of week; Mon = month;    */
   /* 99 = day of month; 99:99:99 = current hour:min:sec; yyyy = current year */

   timeString = ctime (tptr);
   printf ("The current date/time is: %s\n", timeString);


   /* Call localtime and gmtime and then echo the fields to the screen. */

   TM = localtime (tptr);
   if (TM == NULL)
       goto Fail;
   printf ("localtime is:\n");
   printf ("sec = %d  min = %d  hour = %d  day = %d  month = %d  year = %d\n",
           TM->tm_sec, TM->tm_min, TM->tm_hour, TM->tm_mday, TM->tm_mon,
           TM->tm_year);
   printf ("day of week = %d  day of year = %d  not daylight savings = %d\n\n",
           TM->tm_wday, TM->tm_yday, TM->tm_isdst);

   TM = gmtime (tptr);
   if (TM == NULL)
       goto Fail;
   printf ("gmtime is:\n");
   printf ("sec = %d  min = %d  hour = %d  day = %d  month = %d  year = %d\n",
           TM->tm_sec, TM->tm_min, TM->tm_hour, TM->tm_mday, TM->tm_mon,
           TM->tm_year);
   printf ("day of week = %d  day of year = %d  not daylight savings = %d\n\n",
           TM->tm_wday, TM->tm_yday, TM->tm_isdst);


   /* Test mktime: should return original time as returned by time. */

   secondTime = mktime (TM);
   if (secondTime != theTime)
       goto Fail;


   /* Test asctime: should return same time as returned by ctime. */

   timeString = asctime (TM);
   printf ("The current date/time is: %s\n", timeString);


   /* Test difftime.  Value returned should be zero. */

   d = difftime (theTime, secondTime);
   if (d != 0.0)
       goto Fail;

   return;

Fail:
   printf ("Call to a time function in spc20.2.0.1\n");
  }
