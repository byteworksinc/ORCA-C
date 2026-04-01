/*
 * Test C23 <time.h> additions.
 */

#include <stdio.h>
#include <time.h>

int main(void) {
        struct timespec ts;
        struct tm tm, tm2000 = {}, *ptm;
        time_t t, t2000;

        // test timespec_getres

        if (timespec_getres(&ts, TIME_UTC) != TIME_UTC)
                goto Fail;
        if (ts.tv_sec == 0 && ts.tv_nsec == 0)
                goto Fail;
#ifdef __ORCAC__
        if (ts.tv_sec != 1 || ts.tv_nsec != 0)
                goto Fail;
        if (timespec_getres(&ts, 12345) != 0)
                goto Fail;
#endif

        // test localtime_r, gmtime_r, and timegm

        time(&t);
        
        tm2000.tm_year = 2000 - 1900;
        tm2000.tm_mon = 0;
        tm2000.tm_mday = 1;
        tm2000.tm_hour = 0;
        tm2000.tm_min = 0;
        tm2000.tm_sec = 0;
        tm2000.tm_isdst = -1;
        
        t2000 = timegm(&tm2000);

        if (localtime_r(&t, &tm) != &tm)
                goto Fail;
        ptm = localtime(&t);
        if (localtime_r(&t2000, &tm2000) != &tm2000)
                goto Fail;

        if (ptm == NULL)
                goto Fail;
        if (tm.tm_sec != ptm->tm_sec)
                goto Fail;
        if (tm.tm_min != ptm->tm_min)
                goto Fail;
        if (tm.tm_hour != ptm->tm_hour)
                goto Fail;
        if (tm.tm_mday != ptm->tm_mday)
                goto Fail;
        if (tm.tm_mon != ptm->tm_mon)
                goto Fail;
        if (tm.tm_year != ptm->tm_year)
                goto Fail;
        if (tm.tm_wday != ptm->tm_wday)
                goto Fail;
        if (tm.tm_yday != ptm->tm_yday)
                goto Fail;
        if (tm.tm_isdst != ptm->tm_isdst)
                goto Fail;

        if (gmtime_r(&t, &tm) != &tm)
                goto Fail;
        ptm = gmtime(&t);
        tm2000.tm_year = tm2000.tm_mon = tm2000.tm_mday = 0;
        tm2000.tm_hour = tm2000.tm_min = tm2000.tm_sec = 0;
        if (gmtime_r(&t2000, &tm2000) != &tm2000)
                goto Fail;

        if (ptm == NULL)
                goto Fail;
        if (tm.tm_sec != ptm->tm_sec)
                goto Fail;
        if (tm.tm_min != ptm->tm_min)
                goto Fail;
        if (tm.tm_hour != ptm->tm_hour)
                goto Fail;
        if (tm.tm_mday != ptm->tm_mday)
                goto Fail;
        if (tm.tm_mon != ptm->tm_mon)
                goto Fail;
        if (tm.tm_year != ptm->tm_year)
                goto Fail;
        if (tm.tm_wday != ptm->tm_wday)
                goto Fail;
        if (tm.tm_yday != ptm->tm_yday)
                goto Fail;
        if (tm.tm_isdst != ptm->tm_isdst)
                goto Fail;

        if (tm2000.tm_year != 2000 - 1900)
                goto Fail;
        if (tm2000.tm_mon != 0)
                goto Fail;
        if (tm2000.tm_mday != 1)
                goto Fail;
        if (tm2000.tm_hour != 0 || tm2000.tm_min != 0 || tm2000.tm_sec != 0)
                goto Fail;

        if (timegm(&tm2000) != t2000)
                goto Fail;
        if (timegm(&tm) != t)
                goto Fail;

        printf ("Passed Conformance Test c23time\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23time\n");
}
