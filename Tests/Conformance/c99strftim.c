/*
 * Test strftime function, including C99 additions.
 */

#include <stdio.h>
#include <string.h>
#include <time.h>

int main(void) {
        char buf[300];
        struct tm tm = {0};
        size_t len;
        
        tm.tm_year = 2021 - 1900;
        tm.tm_mon = 11;
        tm.tm_mday = 31;
        tm.tm_hour = 14;
        tm.tm_min = 5;
        tm.tm_sec = 2;
        tm.tm_wday = 5;
        tm.tm_yday = 364;
        tm.tm_isdst = 0;
        
        len = strftime(buf, sizeof(buf),
                "%a,%A,%b,%B,%c,%C,%d,%D,%e,%F,%g,%G,%h,%H,%I,%j,%m,%M,%p,%r,"
                "%R,%S,%T,%u,%U,%V,%w,%W,%x,%X,%y,%Y,%%,%Ec,%EC,%Ex,%EX,"
                "%Ey,%EY,%Od,%Oe,%OH,%OI,%Om,%OM,%OS,%Ou,%OU,%OV,%Ow,%OW,%Oy,"
                "%t,%n",
                &tm);
        if (len != 274)
                goto Fail;
        if (strcmp(buf, 
                "Fri,Friday,Dec,December,Fri Dec 31 14:05:02 2021,20,31,"
                "12/31/21,31,2021-12-31,21,2021,Dec,14,02,365,12,05,PM,"
                "02:05:02 PM,14:05,02,14:05:02,5,52,52,5,52,12/31/21,14:05:02,"
                "21,2021,%,Fri Dec 31 14:05:02 2021,20,12/31/21,14:05:02,21,"
                "2021,31,31,14,02,12,05,02,5,52,52,5,52,21,\t,\n") != 0)
                goto Fail;

        tm.tm_year = 2022 - 1900;
        tm.tm_mon = 0;
        tm.tm_mday = 1;
        tm.tm_hour = 0;
        tm.tm_min = 59;
        tm.tm_sec = 59;
        tm.tm_wday = 6;
        tm.tm_yday = 0;
        tm.tm_isdst = 0;

        len = strftime(buf, sizeof(buf),
                "%a,%A,%b,%B,%c,%C,%d,%D,%e,%F,%g,%G,%h,%H,%I,%j,%m,%M,%p,%r,"
                "%R,%S,%T,%u,%U,%V,%w,%W,%x,%X,%y,%Y,%%,%Ec,%EC,%Ex,%EX,"
                "%Ey,%EY,%Od,%Oe,%OH,%OI,%Om,%OM,%OS,%Ou,%OU,%OV,%Ow,%OW,%Oy,"
                "%t,%n",
                &tm);
        if (len != 275)
                goto Fail;
        if (strcmp(buf, 
                "Sat,Saturday,Jan,January,Sat Jan  1 00:59:59 2022,20,01,"
                "01/01/22, 1,2022-01-01,21,2021,Jan,00,12,001,01,59,AM,"
                "12:59:59 AM,00:59,59,00:59:59,6,00,52,6,00,01/01/22,00:59:59,"
                "22,2022,%,Sat Jan  1 00:59:59 2022,20,01/01/22,00:59:59,22,"
                "2022,01, 1,00,12,01,59,59,6,00,52,6,00,22,\t,\n"
                ) != 0)
                goto Fail;

        if (strftime(buf, 1, "%A", &tm) != 0)
                goto Fail;

        printf ("Passed Conformance Test c99strftim\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99strftim\n");
}
