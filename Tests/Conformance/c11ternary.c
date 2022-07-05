/*
 * Test the ? : operator.
 *
 * The basic properties tested should hold back to C89,
 * but a C11 feature (_Generic) is used to test them.
 */

#include <stdio.h>

#define assert_type(e,t) (void)_Generic((e), t:(e))
#define assert_type_val(e,t,v) if (_Generic((e), t:(e)) != (v)) goto Fail

int main(void) {
        int i = 1;
        long l = 2;
        double d = 3;
        struct S {int i;} s = {4};
        const struct S t = {5};
        const void *cvp = &s;
        void *vp = &d;
        const int *cip = &i;
        volatile int *vip = 0;
        int *ip = &i;
        const char *ccp = 0;
        int (*fp1)() = 0;
        int (*fp2)(int (*)[40]) = 0;
        int (*fp3)(int (*)[]) = 0;
        
        assert_type_val(1?i:l, long, 1);
        assert_type_val(1?d:i, double, 3.0);
        assert_type(1?s:t, struct S);
        1?(void)2:(void)3;
        assert_type_val(1?ip:ip, int *, &i);
        assert_type_val(1?ip:cip, const int *, &i);
        assert_type_val(1?cip:ip, const int *, &i);
        assert_type_val(1?0:ip, int *, (void*)0);
        assert_type_val(0?0LL:ip, int *, &i);
        assert_type_val(1?(void*)0:ip, int *, (void*)0);
        assert_type_val(1?cip:0, const int *, &i);
        assert_type_val(1?cip:0LL, const int *, &i);
        assert_type_val(1?cip:(char)0.0, const int *, &i);
        assert_type_val(1?cip:(void*)0, const int *, &i);
        assert_type_val(1?(void*)(void*)0:ip, void *, (void*)0);
        assert_type_val(1?(void*)ip:ip, void *, &i);
        assert_type_val(1?cip:(void*)(void*)0, const void *, &i);
        assert_type_val(1?(void*)ip:cip, const void *, &i);
        assert_type_val(1?main:main, int(*)(void), main);
        assert_type_val(1?main:0, int(*)(void), main);
        assert_type_val(1?(const void*)cip:(void*)ip, const void *, &i);
        assert_type_val(1?cvp:cip, const void *, &s);
        assert_type_val(1?vip:0, volatile int *, (int*)0);
        assert_type_val(1?cip:vip, const volatile int *, &i);
        assert_type_val(1?vp:ccp, const void *, &d);
        assert_type_val(1?ip:cip, const int *, &i);
        assert_type_val(1?vp:ip, void *, &d);
        assert_type_val(1?fp1:fp2, int (*)(int (*)[40]), (void*)0);
        assert_type_val(1?fp2:fp3, int (*)(int (*)[40]), (void*)0);
        assert_type_val(1?fp2:0, int (*)(int (*)[40]), (void*)0);
        assert_type_val(1?fp2:(void*)0, int (*)(int (*)[40]), (void*)0);
        assert_type_val(1?2:3, int, 2);
        assert_type_val(1?2:3U, unsigned int, 2);
        assert_type_val(1?2:3L, long, 2);
        assert_type_val(1?2:3UL, unsigned long, 2);
        assert_type_val(1?2:3LL, long long, 2);
        assert_type_val(1?2:3ULL, unsigned long long, 2);
        assert_type_val(0?2:3, int, 3);
        assert_type_val(0?2U:3, unsigned int, 3);
        assert_type_val(0?2L:3, long, 3);
        assert_type_val(0?2UL:3, unsigned long, 3);
        assert_type_val(0?2LL:3, long long, 3);
        assert_type_val(0?2ULL:3, unsigned long long, 3);
        assert_type_val(1?50000U:3LL, long long, 50000);
        assert_type_val(1?5000000L:3LL, long long, 5000000);

        printf ("Passed Conformance Test c11ternary\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c11ternary\n");
}
