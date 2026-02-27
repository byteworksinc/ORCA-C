/*
 * Test C23 enum features.
 */

#include <limits.h>
#include <stdint.h>
#include <stdio.h>

#define assert_type(e,t) _Generic((e), t:(e))

int main(void) {
        enum A {A1 = -100000, A2, A3 = 100000, A4};
        if (A1 != -100000 || A2 != -99999 || A3 != 100000 || A4 != 100001
                || (enum A)A1 != -100000 || (enum A)A4 != 100001)
                goto Fail;

        enum B {B1 = -1000000000000, B2, B3 = 1000000000000, B4};
        if (B1 != -1000000000000 || B2 != -999999999999
                || B3 != 1000000000000 || B4 != 1000000000001
                || (enum B)B1 != -1000000000000 || (enum B)B4 != 1000000000001)
                goto Fail;

        enum C {C1 = INT_MIN, C2 = sizeof(C1), C3 = 100000, C4 = sizeof(C3),
                C5 = sizeof(C1), C6 = 1000000000000, C7 = sizeof(C1),
                C8 = sizeof(C3)};
        if (C1 != INT_MIN || C2 != sizeof(int) || C3 != 100000
                || C4 != sizeof(100000) || C5 != C2 || C6 != 1000000000000
                || C7 != sizeof(int) || C8 != C4
                || sizeof(C1) < sizeof(1000000000000))
                goto Fail;

#if INT_MAX < INTMAX_MAX
        enum D {D1 = INT_MAX, D2, D3, D4 = sizeof(D1)};
        if (D1 != INT_MAX || D2-D1 != 1 || D3-D1 != 2 || D4 != sizeof(int)
                || sizeof(D1) < sizeof(D3) || sizeof(D4) < sizeof(D2))
                goto Fail;
#endif

#if LONG_MAX < INTMAX_MAX
        enum E {E1 = LONG_MAX, E2, E3, E4 = sizeof(E1)};
        if (E1 != LONG_MAX || E2-E1 != 1 || E3-E1 != 2 || E4 != sizeof(long)
                || sizeof(E1) < sizeof(E3) || sizeof(E4) < sizeof(E2))
                goto Fail;
#endif

        enum F {F1 = 1000000000000, F2 = 1, F3, F4 = sizeof(F2),
                F5 = sizeof(F3)};
        if (F1 != 1000000000000 || F2 != 1 || F3 != 2 || F4 != sizeof(int)
                || F5 != sizeof(int) || sizeof(F3) != sizeof(F1))
                goto Fail;

        enum G {G1 = 10L, G2 = 10LL, G3 = 10ULL};
        if (G1 != 10 || G2 != 10|| G3 != 10)
                goto Fail;
        assert_type(G1, int);
        assert_type(G2, int);
        assert_type(G3, int);
 
        enum H {H1 = 10L, H2 = 1000000000000, H3 = 10ULL, H4 = sizeof(H1),
                H5 = sizeof(H3), H6 = assert_type(H3, int)};
        if (H1 != 10 || H2 != 1000000000000 || H3 != 10 || H4 != sizeof(int)
                || H5 != sizeof(int) || H6 != H3)
                goto Fail;

#if INT_MIN != INTMAX_MIN
        enum I {I1 = (intmax_t)INT_MIN-1, I2, I3 = -1, I4};
        if (I1 != (intmax_t)INT_MIN-1 || I2 != INT_MIN || I3 != -1 || I4 != 0)
                goto Fail;
#endif

#if LONG_MIN != INTMAX_MIN
        enum J {J1 = (intmax_t)LONG_MIN-1, J2, J3 = -1, J4};
        if (J1 != (intmax_t)LONG_MIN-1 || J2 != LONG_MIN || J3 != -1 || J4 != 0)
                goto Fail;
#endif

        enum K : unsigned {K1, K2, K3 = 65000, K4 = sizeof(K1)};
        if (K1 != 0 || K2 != 1 || K3 != 65000 || K4 != sizeof(unsigned))
                goto Fail;
        assert_type(K1, unsigned);
        assert_type(K2, unsigned);
        assert_type(K3, unsigned);
        assert_type(K4, unsigned);

        enum L : long {L1, L2, L3 = -100000, L4 = sizeof(L1)};
        if (L1 != 0 || L2 != 1 || L3 != -100000 || L4 != sizeof(long))
                goto Fail;
        assert_type(L1, long);
        assert_type(L2, long);
        assert_type(L3, long);
        assert_type(L4, long);

        enum M : long long {M1, M2, M3 = -1000000000000, M4 = 1000000000000};
        if (M1 != 0 || M2 != 1 || M3 != -1000000000000 || M4 != 1000000000000)
                goto Fail;
        assert_type(M1, long long);
        assert_type(M2, long long);
        assert_type(M3, long long);
        assert_type(M4, long long);

        enum N : unsigned long long {N1 = LLONG_MAX, N2, N3 = ULLONG_MAX};
        if (N1 != LLONG_MAX || N2 != (unsigned long long)LLONG_MAX + 1
                || N3 != ULLONG_MAX)
                goto Fail;
        assert_type(N1, unsigned long long);
        assert_type(N2, unsigned long long);
        assert_type(N3, unsigned long long);

        enum O : signed char {O1 = -128, O2 = 127, O3 = sizeof(O1)};
        if (O1 != -128 || O2 != 127 || O3 != 1)
                goto Fail;
        assert_type((enum O)O1, signed char);
        assert_type(O1, signed char);
        assert_type(O2, signed char);
        assert_type(O3, signed char);

        enum P : _Bool {P1, P2};
        if (P1 != 0 || P2 != 1 || (enum P)123 != 1 || (enum P)main != 1)
                goto Fail;
        enum P p = A1;
        if (p != 1)
                goto Fail;
        assert_type(P1, _Bool);
        assert_type(P2, _Bool);

        enum Q {Q1, Q2 = 101, Q3 = 100};
        enum Q {Q3 = 100, Q2, Q1 = Q1};

        enum R : short;
        enum R r;
        enum R : short {R1 = 123};
        enum R : short;

        enum S : unsigned long {S1 = (enum S)1000000};
        {
                enum S s = S1;
                enum S : char {S1, S2};
                if (s == S1)
                        goto Fail;
        }

#if __STDC_VERSION__ >= 202311L
        enum T : typeof(1+(enum T : int {T1,T2})0);
        if (T1 != 0 || T2 != 1)
                goto Fail;
        assert_type(T1, int);
#endif

        enum : unsigned char {U1 = 20, U2, U3 = 255,};
        if (U1 != 20 || U2 != 21 || U3 != 255)
                goto Fail;

        printf ("Passed Conformance Test c23enum\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23enum\n");
}
