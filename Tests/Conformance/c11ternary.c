/*
 * Test the ? : operator.
 *
 * The basic properties tested should hold back to C89,
 * but a C11 feature (_Generic) is used to test them.
 */

#define assert_type(e,t) (void)_Generic((e), t:(e))

int main(void) {
        int i = 1;
        long l = 2;
        double d = 3;
        struct S {int i;} s = {4};
        const struct S t = {5};
        const void *cvp = &i;
        void *vp = &i;
        const int *cip = &i;
        volatile int *vip = 0;
        int *ip = &i;
        const char *ccp = 0;
        int (*fp1)() = 0;
        int (*fp2)(int (*)[40]) = 0;
        int (*fp3)(int (*)[]) = 0;
        
        assert_type(1?i:l, long);
        assert_type(1?d:i, double);
        assert_type(1?s:t, struct S);
        1?(void)2:(void)3;
        assert_type(1?ip:ip, int *);
        assert_type(1?ip:cip, const int *);
        assert_type(1?cip:ip, const int *);
        assert_type(1?0:ip, int *);
        assert_type(0?0LL:ip, int *);
        assert_type(1?(void*)0:ip, int *);
        assert_type(1?cip:0, const int *);
        assert_type(1?cip:0LL, const int *);
        assert_type(1?cip:(char)0.0, const int *);
        assert_type(1?cip:(void*)0, const int *);
        assert_type(1?(void*)(void*)0:ip, void *);
        assert_type(1?(void*)ip:ip, void *);
        assert_type(1?cip:(void*)(void*)0, const void *);
        assert_type(1?(void*)ip:cip, const void *);
        assert_type(1?main:main, int(*)(void));
        assert_type(1?main:0, int(*)(void));
        assert_type(1?(const void*)cip:(void*)ip, const void *);
        assert_type(1?cvp:cip, const void *);
        assert_type(1?vip:0, volatile int *);
        assert_type(1?cip:vip, const volatile int *);
        assert_type(1?vp:ccp, const void *);
        assert_type(1?ip:cip, const int *);
        assert_type(1?vp:ip, void *);
        assert_type(1?fp1:fp2, int (*)(int (*)[40]));
        assert_type(1?fp2:fp3, int (*)(int (*)[40]));
        assert_type(1?fp2:0, int (*)(int (*)[40]));
        assert_type(1?fp2:(void*)0, int (*)(int (*)[40]));
}
