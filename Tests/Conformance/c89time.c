/*
 * Test <time.h> functions (C89).
 */

#include <time.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>

int main(void) {
        clock_t clock_start;
        time_t time_start;
        struct tm tm1, tm2;
        time_t time1, time2;
        char buf[20];
        
        clock_start = clock();
        time(&time_start);
        
        tm1.tm_year = 2023 - 1900;
        tm1.tm_mon = 1 - 1;
        tm1.tm_mday = 5;
        tm1.tm_hour = 18;
        tm1.tm_min = 25;
        tm1.tm_sec = 54;
        tm1.tm_isdst = -1;
        tm1.tm_wday = 4;
        
        if (strcmp(asctime(&tm1), "Thu Jan  5 18:25:54 2023\n") != 0)
                goto Fail;
        
        tm1.tm_wday = -12345;
        tm1.tm_yday = 12345;
        time1 = mktime(&tm1);
        if (tm1.tm_wday != 4)
                goto Fail;
        if (tm1.tm_yday != 4)
                goto Fail;
                
        if (strcmp(ctime(&time1), "Thu Jan  5 18:25:54 2023\n") != 0)
                goto Fail;
        
        if (strcmp(asctime(&tm1), "Thu Jan  5 18:25:54 2023\n") != 0)
                goto Fail;

        tm1.tm_year = 1978 - 1900;
        tm1.tm_mon = 12 - 1;
        tm1.tm_mday = 29;
        tm1.tm_hour = 4;
        tm1.tm_min = 2;
        tm1.tm_sec = 5;
        tm1.tm_isdst = -1;
        tm1.tm_wday = 5;

        if (strcmp(asctime(&tm1), "Fri Dec 29 04:02:05 1978\n") != 0)
                goto Fail;

        tm1.tm_wday = -12345;
        tm1.tm_yday = 12345;
        time1 = mktime(&tm1);
        if (tm1.tm_wday != 5)
                goto Fail;
        if (tm1.tm_yday != 362)
                goto Fail;

        if (strcmp(asctime(&tm1), "Fri Dec 29 04:02:05 1978\n") != 0)
                goto Fail;

        if (strcmp(ctime(&time1), "Fri Dec 29 04:02:05 1978\n") != 0)
                goto Fail;

        tm1.tm_year = 2001 - 1900 - 2730 - 3;
        tm1.tm_mon = 32760;
        tm1.tm_mday = 31;
        tm1.tm_hour = 26280;
        tm1.tm_min = -20;
        tm1.tm_sec = 32400;
        tm1.tm_isdst = -1;
        tm1.tm_wday = -12345;
        time1 = mktime(&tm1);
        
        if (tm1.tm_yday != 29)
                goto Fail;

        if (strcmp(ctime(&time1), "Tue Jan 30 08:40:00 2001\n") != 0)
                goto Fail;
        
        if (strcmp(asctime(localtime(&time1)), "Tue Jan 30 08:40:00 2001\n") != 0)
                goto Fail;

        tm1.tm_year = 2001 - 1900 + 2730 + 3;
        tm1.tm_mon = -32760;
        tm1.tm_mday = 31 - 366;
        tm1.tm_hour = -26280;
        tm1.tm_min = +200;
        tm1.tm_sec = 32400;
        tm1.tm_isdst = -1;
        tm1.tm_wday = -12345;
        time1 = mktime(&tm1);
        
        if (tm1.tm_yday != 30)
                goto Fail;
        
        if (strcmp(asctime(localtime(&time1)), "Mon Jan 31 12:20:00 2000\n") != 0)
                goto Fail;

        if (strcmp(ctime(&time1), "Mon Jan 31 12:20:00 2000\n") != 0)
                goto Fail;
        
        if (strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S", &tm1) != 19)
                goto Fail;
        if (strcmp(buf, "2000-01-31 12:20:00") != 0)
                goto Fail;

        tm1.tm_sec += 100;
        time2 = mktime(&tm1);
        if (difftime(time2, time1) != 100)
                goto Fail;

        tm2 = *gmtime(&time1);
        if (tm2.tm_year != tm1.tm_year)
                goto Fail;
        if (tm2.tm_mon != tm1.tm_mon)
                goto Fail;
        if (abs(tm2.tm_mday - tm1.tm_mday) > 1)
                goto Fail;

        /* Test limits of time_t in ORCA/C */

        tm1.tm_year = 1969 - 1900;
        tm1.tm_mon = 11 - 1;
        tm1.tm_mday = 13;
        tm1.tm_hour = 0;
        tm1.tm_min = 0;
        tm1.tm_sec = 0;
        tm1.tm_isdst = -1;
        tm1.tm_wday = -12345;
        time1 = mktime(&tm1);

        if (strcmp(ctime(&time1), "Thu Nov 13 00:00:00 1969\n") != 0)
                goto Fail;

        tm1.tm_year = 2105 - 1900;
        tm1.tm_mon = 12 - 1;
        tm1.tm_mday = 20;
        tm1.tm_hour = 6;
        tm1.tm_min = 28;
        tm1.tm_sec = 15;
        tm1.tm_isdst = -1;
        tm1.tm_wday = -12345;
        time1 = mktime(&tm1);
        
        if (strcmp(ctime(&time1), "Sun Dec 20 06:28:15 2105\n") != 0)
                goto Fail;

        if (clock() - clock_start < 0)
                goto Fail;
        if (difftime(time(NULL), time_start) < 0)
                goto Fail;

        printf ("Passed Conformance Test c89time\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c89time\n");
}
