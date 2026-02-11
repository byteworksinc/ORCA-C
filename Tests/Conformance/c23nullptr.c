/*
 * Test nullptr keyword and nullptr_t type (C23).
 *
 * This will only work in a C23 language mode.
 */

#include <stddef.h>
#include <stdio.h>

#if __STDC_VERSION__ < 202311L
#error This is not expected to work in pre-C23 language versions.
#else

#define assert_nullptr_type(e) _Generic((e), nullptr_t: (e))

static_assert(sizeof(nullptr_t) == sizeof(char*));
static_assert(alignof(nullptr_t) == alignof(char*));

nullptr_t np1;
auto np2 = nullptr;
typeof(nullptr) np3 = 0;
typeof(nullptr_t) np4;
typeof(np1) np4 = (void*)0;
nullptr_t npa[10];

nullptr_t npf(nullptr_t np) {
        return np;
}

int main(void) {
        nullptr_t np5 = NULL;
        auto np6 = nullptr;
        const typeof(nullptr) np7 = 0;
        volatile typeof(np1) np8 = (void*)0;
        nullptr_t *npp = &np1;

        if (np1 || np2 || np3 || np4 || np5 || np6 || np7 || np8 || *npp)
                goto Fail;

        np1 = 0;
        np2 = (void*)0;
        np3 = NULL;
        np4 = nullptr;
        np8 = np5;
        
        if (np1 || np2 || np3 || np4 || np8 || nullptr)
                goto Fail;

        int *ip = nullptr;
        double *dp = np1;
        const void *vp = np2;
        int (*fp)(void) = *npp;
        bool b = np5;
        
        if (ip || dp || vp || fp || b)
                goto Fail;

        ip = nullptr;
        dp = *npp;
        vp = nullptr;
        fp = np3;
        b = np7;
        
        if (ip || dp || vp || fp || b)
                goto Fail;

        assert_nullptr_type(np1);
        assert_nullptr_type(np2);
        assert_nullptr_type(np3);
        assert_nullptr_type(np4);
        assert_nullptr_type(np5);
        assert_nullptr_type(np6);
        assert_nullptr_type(np7);
        assert_nullptr_type(np8);
        assert_nullptr_type(npa[0]);

        if (np1 != np2)
                goto Fail;
        if (0 != np3)
                goto Fail;
        if (np4 != nullptr)
                goto Fail;
        if ((void*)0 != np5)
                goto Fail;
        if (np6 == main)
                goto Fail;
        if (&np1 == np7)
                goto Fail;
        if (np8 != *npp)
                goto Fail;
        if (nullptr == npp)
                goto Fail;
        if (nullptr != nullptr)
                goto Fail;

        if (nullptr)
                goto Fail;
        if (np1)
                goto Fail;
        if (*npp)
                goto Fail;

        (void)nullptr;
        (void)np2;
        (void)*npp;
        
        if ((bool)nullptr)
                goto Fail;
        if ((bool)np3)
                goto Fail;
        if ((bool)*npp)
                goto Fail;
        
        if ((void*)nullptr)
                goto Fail;
        if ((int*)np4 != NULL)
                goto Fail;
        if ((int(*)())*npp != 0)
                goto Fail;

        if ((nullptr_t)nullptr)
                goto Fail;
        if ((nullptr_t)np5)
                goto Fail;
        if ((typeof(nullptr))*npp)
                goto Fail;

        if ((nullptr_t)0)
                goto Fail;
        if ((nullptr_t)(void*)0)
                goto Fail;
        if ((typeof(nullptr))NULL)
                goto Fail;        

        if (npf(0))
                goto Fail;

        assert_nullptr_type(1 ? nullptr : np1);
        assert_nullptr_type(0 ? nullptr : nullptr);
        assert_nullptr_type(*(1 ? npp : *npp));

        if ((np8 ? nullptr : npp) != &np1)
                goto Fail;
        if (nullptr ? npp : np1)
                goto Fail;
        if (*(!np7 ? npp : *npp))
                goto Fail;

        printf ("Passed Conformance Test c23nullptr\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23nullptr\n");
}

#endif
