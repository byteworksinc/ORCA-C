/*
 * Test support for 0B/0b prefixes in strto* functions (C23).
 */

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <errno.h>

int main(void) {
        char *end;

#if __STDC_VERSION__ >= 202311L
        if (strtoul("0b10101011110011010001001000110100", NULL, 0) != 0xabcd1234)
                goto Fail;
        if (strtoul("0b101010111100110100010010001101002", NULL, 2) != 0xabcd1234)
                goto Fail;
        if (strtoul("0B101010111100110100010010001101002", NULL, 0) != 0xabcd1234)
                goto Fail;
        if (strtoul("0B10101011110011010001001000110100", NULL, 2) != 0xabcd1234)
                goto Fail;
        if (strtoul(" +0b101010111100110100010010001101002", NULL, 0) != 0xabcd1234)
                goto Fail;
        if (strtoul(" +0b10101011110011010001001000110100", NULL, 2) != 0xabcd1234)
                goto Fail;
        if (strtoul(" 0B10101011110011010001001000110100", &end, 0) != 0xabcd1234)
                goto Fail;
        if (*end != 0)
                goto Fail;
        if (strtoul(" 0B101010111100110100010010001101002", &end, 2) != 0xabcd1234)
                goto Fail;
        if (*end != '2')
                goto Fail;

        if (strtoull("0b1010101111001101111011110001001000110100010101100111100010010000", NULL, 0) != 0xabcdef1234567890)
                goto Fail;
        if (strtoull("0b10101011110011011110111100010010001101000101011001111000100100002", NULL, 2) != 0xabcdef1234567890)
                goto Fail;
        if (strtoull("0B10101011110011011110111100010010001101000101011001111000100100002", NULL, 0) != 0xabcdef1234567890)
                goto Fail;
        if (strtoull("0B1010101111001101111011110001001000110100010101100111100010010000", NULL, 2) != 0xabcdef1234567890)
                goto Fail;
        if (strtoull(" +0B10101011110011011110111100010010001101000101011001111000100100002", NULL, 0) != 0xabcdef1234567890)
                goto Fail;
        if (strtoull(" +0B1010101111001101111011110001001000110100010101100111100010010000", NULL, 2) != 0xabcdef1234567890)
                goto Fail;
        if (strtoull(" 0b1010101111001101111011110001001000110100010101100111100010010000", &end, 0) != 0xabcdef1234567890)
                goto Fail;
        if (*end != 0)
                goto Fail;
        if (strtoull(" 0b10101011110011011110111100010010001101000101011001111000100100002", &end, 2) != 0xabcdef1234567890)
                goto Fail;
        if (*end != '2')
                goto Fail;

        if (strtoumax("0b1010101111001101111011110001001000110100010101100111100010010000", NULL, 0) != 0xabcdef1234567890)
                goto Fail;
        if (strtoumax("0b10101011110011011110111100010010001101000101011001111000100100002", NULL, 2) != 0xabcdef1234567890)
                goto Fail;
        if (strtoumax("0B10101011110011011110111100010010001101000101011001111000100100002", NULL, 0) != 0xabcdef1234567890)
                goto Fail;
        if (strtoumax("0B1010101111001101111011110001001000110100010101100111100010010000", NULL, 2) != 0xabcdef1234567890)
                goto Fail;
        if (strtoumax(" +0B10101011110011011110111100010010001101000101011001111000100100002", NULL, 0) != 0xabcdef1234567890)
                goto Fail;
        if (strtoumax(" +0B1010101111001101111011110001001000110100010101100111100010010000", NULL, 2) != 0xabcdef1234567890)
                goto Fail;
        if (strtoumax(" 0b1010101111001101111011110001001000110100010101100111100010010000", &end, 0) != 0xabcdef1234567890)
                goto Fail;
        if (*end != 0)
                goto Fail;
        if (strtoumax(" 0b10101011110011011110111100010010001101000101011001111000100100002", &end, 2) != 0xabcdef1234567890)
                goto Fail;
        if (*end != '2')
                goto Fail;

        if (strtol("0b1101011110011010001001000110100", NULL, 0) != 0x6bcd1234)
                goto Fail;
        if (strtol("0b11010111100110100010010001101002", NULL, 2) != 0x6bcd1234)
                goto Fail;
        if (strtol("0B11010111100110100010010001101002", NULL, 0) != 0x6bcd1234)
                goto Fail;
        if (strtol("0B1101011110011010001001000110100", NULL, 2) != 0x6bcd1234)
                goto Fail;
        if (strtol(" +0b11010111100110100010010001101002", NULL, 0) != 0x6bcd1234)
                goto Fail;
        if (strtol(" +0b1101011110011010001001000110100", NULL, 2) != 0x6bcd1234)
                goto Fail;
        if (strtol(" 0B1101011110011010001001000110100", &end, 0) != 0x6bcd1234)
                goto Fail;
        if (*end != 0)
                goto Fail;
        if (strtol(" 0B11010111100110100010010001101002", &end, 2) != 0x6bcd1234)
                goto Fail;
        if (*end != '2')
                goto Fail;

        if (strtoll("0b110101111001101111011110001001000110100010101100111100010010000", NULL, 0) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoll("0b1101011110011011110111100010010001101000101011001111000100100002", NULL, 2) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoll("0B1101011110011011110111100010010001101000101011001111000100100002", NULL, 0) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoll("0B110101111001101111011110001001000110100010101100111100010010000", NULL, 2) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoll(" +0B1101011110011011110111100010010001101000101011001111000100100002", NULL, 0) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoll(" +0B110101111001101111011110001001000110100010101100111100010010000", NULL, 2) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoll(" 0b110101111001101111011110001001000110100010101100111100010010000", &end, 0) != 0x6bcdef1234567890)
                goto Fail;
        if (*end != 0)
                goto Fail;
        if (strtoll(" 0b1101011110011011110111100010010001101000101011001111000100100002", &end, 2) != 0x6bcdef1234567890)
                goto Fail;
        if (*end != '2')
                goto Fail;

        if (strtoimax("0b110101111001101111011110001001000110100010101100111100010010000", NULL, 0) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoimax("0b1101011110011011110111100010010001101000101011001111000100100002", NULL, 2) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoimax("0B1101011110011011110111100010010001101000101011001111000100100002", NULL, 0) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoimax("0B110101111001101111011110001001000110100010101100111100010010000", NULL, 2) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoimax(" +0B1101011110011011110111100010010001101000101011001111000100100002", NULL, 0) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoimax(" +0B110101111001101111011110001001000110100010101100111100010010000", NULL, 2) != 0x6bcdef1234567890)
                goto Fail;
        if (strtoimax(" 0b110101111001101111011110001001000110100010101100111100010010000", &end, 0) != 0x6bcdef1234567890)
                goto Fail;
        if (*end != 0)
                goto Fail;
        if (strtoimax(" 0b1101011110011011110111100010010001101000101011001111000100100002", &end, 2) != 0x6bcdef1234567890)
                goto Fail;
        if (*end != '2')
                goto Fail;
#endif

        errno = 0;
        if (strtol("0b2", &end, 2) != 0)
                goto Fail;
        if (errno != 0 || *end != 'b')
                goto Fail;

        errno = 0;
        if (strtoul("0b2", &end, 2) != 0)
                goto Fail;
        if (errno != 0 || *end != 'b')
                goto Fail;

        errno = 0;
        if (strtoll("0b2", &end, 2) != 0)
                goto Fail;
        if (errno != 0 || *end != 'b')
                goto Fail;

        errno = 0;
        if (strtoull("0b2", &end, 2) != 0)
                goto Fail;
        if (errno != 0 || *end != 'b')
                goto Fail;

        errno = 0;
        if (strtoimax("0b2", &end, 2) != 0)
                goto Fail;
        if (errno != 0 || *end != 'b')
                goto Fail;

        errno = 0;
        if (strtoumax("0b2", &end, 2) != 0)
                goto Fail;
        if (errno != 0 || *end != 'b')
                goto Fail;

        if (strtol("0b1", &end, 10) != 0)
                goto Fail;
        if (*end != 'b')
                goto Fail;
        if (strtoimax("0b1", &end, 8) != 0)
                goto Fail;
        if (*end != 'b')
                goto Fail;
        if (strtoull("0b1", &end, 16) != 0xb1)
                goto Fail;
        if (*end != 0)
                goto Fail;

        printf ("Passed Conformance Test c23strto\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23strto\n");
}
