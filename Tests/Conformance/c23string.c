/*
 * Test support for C23 <string.h> features.
 */

#include <stdio.h>
#include <string.h>
#include <stddef.h>

#define assert_type(e,t) (void)_Generic((e), t:0)

char buf[10];

int main(void) {
        int i;

        /* test memset_explicit */
        memset_explicit(buf, 'x', sizeof(buf));
        for (i = 0; i < sizeof(buf); i++) {
                if (buf[i] != 'x')
                        goto Fail;
        }
        memset_explicit(buf, 0x7f00, sizeof(buf));
        for (i = 0; i < sizeof(buf); i++) {
                if (buf[i] != 0)
                        goto Fail;
        }

        /* test memccpy */
        char buf[11] = "1234567890x";
        char hello[] = "HelloWorld";

        if (memccpy(buf, hello, 'x', 0) != NULL)
                goto Fail;
        if (memcmp(buf, "1234567890x", 11) != 0)
                goto Fail;

        if (memccpy(buf, hello, 'o', 10) != buf + 5)
                goto Fail;
        if (memcmp(buf, "Hello67890x", 11) != 0)
                goto Fail;

        if (memccpy(buf, hello, 'Q', 10) != NULL)
                goto Fail;
        if (memcmp(buf, "HelloWorldx", 11) != 0)
                goto Fail;

#if __STDC_VERSION__ >= 202311L
        /* test generic functions */
        static char a[] = "abcdef";

        if (memchr(a, 'x', 6) != NULL)
                goto Fail;
        if (memchr((const char *)a, 'b', 6) != a+1)
                goto Fail;

        assert_type(memchr(a, 'x', 6), void *);
        assert_type(memchr((const char *)a, 'x', 6), const void *);
        assert_type(memchr((void *)a, 'x', 6), void *);
        assert_type(memchr((const void *)a, 'x', 6), const void *);

        assert_type((memchr)((const char *)a, 'x', 6), void *);
        assert_type((memchr)((const void *)a, 'x', 6), void *);

        assert_type(memchr(0, 'x', 6), void *);
        assert_type(memchr((void *)0, 'x', 6), void *);

        if (strchr(a, 'x') != NULL)
                goto Fail;
        if (strchr((const char *)a, 'b') != a+1)
                goto Fail;

        assert_type(strchr(a, 'x'), char *);
        assert_type(strchr((const char *)a, 'x'), const char *);
        assert_type(strchr((void *)a, 'x'), char *);
        assert_type(strchr((const void *)a, 'x'), const char *);

        assert_type((strchr)((const char *)a, 'x'), char *);
        assert_type((strchr)((const void *)a, 'x'), char *);

        assert_type(strchr(0, 'x'), char *);
        assert_type(strchr((void *)0, 'x'), char *);

        if (strrchr(a, 'x') != NULL)
                goto Fail;
        if (strrchr((const char *)a, 'b') != a+1)
                goto Fail;

        assert_type(strrchr(a, 'x'), char *);
        assert_type(strrchr((const char *)a, 'x'), const char *);
        assert_type(strrchr((void *)a, 'x'), char *);
        assert_type(strrchr((const void *)a, 'x'), const char *);

        assert_type((strrchr)((const char *)a, 'x'), char *);
        assert_type((strrchr)((const void *)a, 'x'), char *);

        assert_type(strrchr(0, 'x'), char *);
        assert_type(strrchr((void *)0, 'x'), char *);

        if (strstr(a, "xy") != NULL)
                goto Fail;
        if (strstr((const char *)a, "bc") != a+1)
                goto Fail;

        assert_type(strstr(a, "xy"), char *);
        assert_type(strstr((const char *)a, "xy"), const char *);
        assert_type(strstr((void *)a, "xy"), char *);
        assert_type(strstr((const void *)a, "xy"), const char *);

        assert_type((strstr)((const char *)a, "xy"), char *);
        assert_type((strstr)((const void *)a, "xy"), char *);

        assert_type(strstr(0, "xy"), char *);
        assert_type(strstr((void *)0, "xy"), char *);   

        if (strpbrk(a, "xy") != NULL)
                goto Fail;
        if (strpbrk((const char *)a, "bc") != a+1)
                goto Fail;

        assert_type(strpbrk(a, "xy"), char *);
        assert_type(strpbrk((const char *)a, "xy"), const char *);
        assert_type(strpbrk((void *)a, "xy"), char *);
        assert_type(strpbrk((const void *)a, "xy"), const char *);

        assert_type((strpbrk)((const char *)a, "xy"), char *);
        assert_type((strpbrk)((const void *)a, "xy"), char *);

        assert_type(strpbrk(0, "xy"), char *);
        assert_type(strpbrk((void *)0, "xy"), char *);

#if defined(__ORCAC__) && !defined(__KeepNamespacePure__)
        if (strrpbrk(a, "xy") != NULL)
                goto Fail;
        if (strrpbrk((const char *)a, "bc") != a+2)
                goto Fail;

        assert_type(strrpbrk(a, "xy"), char *);
        assert_type(strrpbrk((const char *)a, "xy"), const char *);
        assert_type(strrpbrk((void *)a, "xy"), char *);
        assert_type(strrpbrk((const void *)a, "xy"), const char *);

        assert_type((strrpbrk)((const char *)a, "xy"), char *);
        assert_type((strrpbrk)((const void *)a, "xy"), char *);

        assert_type(strrpbrk(0, "xy"), char *);
        assert_type(strrpbrk((void *)0, "xy"), char *);
#endif
#endif

        printf ("Passed Conformance Test c23string\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23string\n");
}
