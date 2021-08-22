/*
 * Test the long long type and operations on it (C99).
 */

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <limits.h>

// Preprocessor arithmetic should use (u)intmax_t, which is at least long long
#if 0x1234567800000000 + 0x3333000000000000 != 0x4567567800000000
#error "Preprocessor arithmetic uses a smaller type than is required by C99+"
#endif

long long ll1, ll2, *llp;

static unsigned long long f(long long x, unsigned long long y) {
        return x + y;
}

int main(void) {
        unsigned long long ull1, ull2, *ullp;
        
        ll1 = 0x2142134abc342132;
        ll2 = 0424622122152311057372;
        ull1 = ll1;
        ull2 = ll2;
        
        // C language operations on long long types
        
        if (ll1 + ll2 != 7382622918894190636)
                goto Fail;
        if (ll1 - ll2 != -2589624592053059016)
                goto Fail;
        if (ll1 / ll2 != 0)
                goto Fail;
        if (ll1 % ll2 != 2396499163420565810)
                goto Fail;
        if (-ll1 != -0x2142134abc342132)
                goto Fail;
        if (+ll2 != 0424622122152311057372)
                goto Fail;

        if (ull1 + ull2 != 7382622918894190636)
                goto Fail;
        if (ll1 - ll2 != 15857119481656492600u)
                goto Fail;
        if (ull1 / ull2 != 0)
                goto Fail;
        if (ull1 % ull2 != 2396499163420565810)
                goto Fail;
        if (ull1 * ull2 != 7852775837922281172)
                goto Fail;
        if (-ull1 != 16050244910288985806u)
                goto Fail;
        
        if ((uint8_t)ull1 != 0x32)
                goto Fail;
        if ((uint16_t)ull1 != 0x2132)
                goto Fail;
        if ((uint32_t)ull1 != 0xbc342132)
                goto Fail;
        
        if (sizeof(ll1) < 8)
                goto Fail;
        if (sizeof(unsigned long long) < 8)
                goto Fail;

        ullp = &ull1;
        if ((*ullp)++ != 0x2142134abc342132)
                goto Fail;
        if (ull1 != 0x2142134abc342133)
                goto Fail;
        if (ull1-- != 0x2142134abc342133)
                goto Fail;
        if (ullp[0] != 0x2142134abc342132)
                goto Fail;
        
        llp = &ll1;
        if (--*llp != 0x2142134abc342131)
                goto Fail;
        if (ll1 != 0x2142134abc342131)
                goto Fail;
        if (++ll1 != 0x2142134abc342132)
                goto Fail;
        if (*llp != 0x2142134abc342132)
                goto Fail;
        
        if (ll1 > ll2)
                goto Fail;
        if (ull1 >= ll2)
                goto Fail;
        if (ull2 <= ll1)
                goto Fail;
        if (ll1 < ull1)
                goto Fail;
        if (ll1 != ull1)
                goto Fail;
        if (ull2 == ll1)
                goto Fail;
        
        if ((ll1 && ull2) != 1)
                goto Fail;
        if ((ll2 || 0) != 1)
                goto Fail;
        
        if ((ll1 & ull2) != 0x102010210240032)
                goto Fail;
        if ((ull1 | ll2) != 0x6572576bff347ffa)
                goto Fail;
        if ((ll1 ^ ll2) != 0x64705669ef107fc8)
                goto Fail;
        if (~ull1 != 0xdebdecb543cbdecd)
                goto Fail;

        if (ull1 << 4 != 0x142134abc3421320)
                goto Fail;
        if ((ll1 >>= 40) != 0x214213)
                goto Fail;
        
        ll1 = 0xabcd12345678;
        if ((double)ll1 != 188897262065272.0)
                goto Fail;
        ull1 = (double)ll1;
        if (ull1 != 0xabcd12345678)
                goto Fail;
        if ((double)ull1 != 188897262065272.0)
                goto Fail;
        ll1 = (double)ull1 * 4096.0;
        if (ll1 != 0xabcd12345678000)
                goto Fail;
        
        ull2 = f(ll2, 4);
        if (ull2 != 0424622122152311057376)
                goto Fail;
        unsigned long long (*g)(long long x, unsigned long long y) = f;
        ull2 = g(1, ull2);
        if (ull2 != 0424622122152311057377)
                goto Fail;

        // Library functions on (unsigned) long long or (u)intmax_t
        
        if (llabs(-2143242134213423424) != 2143242134213423424)
                goto Fail;
        if (llabs(534253245325325) != 534253245325325)
                goto Fail;
        if (imaxabs(-34523523456235354) != 34523523456235354)
                goto Fail;
        if (imaxabs(34135353245345) != 34135353245345)
                goto Fail;
        
        lldiv_t d1;
        d1 = lldiv(34532523534523245, 213);
        if (d1.quot != 162124523636259)
                goto Fail;
        if (d1.rem != 78)
                goto Fail;
        d1 = lldiv(-34532523534523245, 213);
        if (d1.quot != -162124523636259)
                goto Fail;
        if (d1.rem != -78)
                goto Fail;
        d1 = lldiv(-34532523534523245, -213);
        if (d1.quot != 162124523636259)
                goto Fail;
        if (d1.rem != -78)
                goto Fail;
        d1 = lldiv(34532523534523245, -213);
        if (d1.quot != -162124523636259)
                goto Fail;
        if (d1.rem != 78)
                goto Fail;
        imaxdiv_t d2;
        d2 = imaxdiv(34532523534523245, 213);
        if (d2.quot != 162124523636259)
                goto Fail;
        if (d2.rem != 78)
                goto Fail;
        
        if (atoll("214214215134634264") != 214214215134634264)
                goto Fail;
        if (strtoll("-sdfsdfsa2142", 0, 30) != -504001881733555022)
                goto Fail;
        if (strtoll("-asfsdfasfsfsfsfasfssdfasfsdfsafff", 0, 35) != LLONG_MIN)
                goto Fail;
        if (strtoull("0xfa24252315abcdef", 0, 0) != 0xfa24252315abcdef)
                goto Fail;
        if (strtoimax("-sdfsdfsa2142", 0, 30) != -504001881733555022)
                goto Fail;
        if (strtoumax("0xfa24252315abcdef", 0, 0) != 0xfa24252315abcdef)
                goto Fail;

        // Constant expressions
        
        static long long sll1 = 
                -(321512542135123451 / 3241241234 * 2353423223)
                + 34547547645634 - 341242134234124;
        if (sll1 != -233752781426004585)
                goto Fail;
        
        static unsigned long long sll2 =
                (0xc345324532452345 & 0xad4312341234abcd) >> 4
                | (0x2453245abcd34534 ^ 0x234213412342134a) << 3;
        if (sll2 != 0x389db9fcfdaaf3f4)
                goto Fail;
        
        static long long sll3 = (long long)10000000000.1;
        if (sll3 != 10000000000)
                goto Fail;
        static double sd1 = (double)-0x12345678abcd;
        if (sd1 != -0x12345678abcd)
                goto Fail;

        printf ("Passed Conformance Test c99llong\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99llong\n");
}
