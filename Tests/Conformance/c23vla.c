/*
 * Test support for VLA types.
 *
 * This tests support for VLA types, but not for local variables of VLA type,
 * matching the C23 requirement to support the former while leaving the latter
 * optional.
 */

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdalign.h>

int good_count = 0, bad_count = 0, optional_count = 0;
int expected_good_count = 0;

#define GOOD_VALUE 3
#define BAD_VALUE 4
#define OPTIONAL_VALUE 5

int good(unsigned long line) {
        good_count++;
        return GOOD_VALUE;
}

int bad(unsigned long line) {
        bad_count++;
        return BAD_VALUE;
}

int optional(unsigned long line) {
        optional_count++;
        return OPTIONAL_VALUE;
}

#define good() good(__LINE__)
#define bad() bad(__LINE__)
#define optional() optional(__LINE__)

void set_vla(int m, int n, int o, int a[m][n][o]) {
        for (int i = 0; i < m; i++) {
                for (int j = 0; j < n; j++) {
                        for (int k = 0; k < o; k++) {
                                a[i][j][k] = i*100 + j*10 + k;
                        }
                }
        }
}

void test_call1(char []);

void test_call1(char [good()]);

void test_call1(char x[good()]) {
}

void test_call2(char x[good()][good()][good()]) {
}

#if __STDC_VERSION__ >= 202311L
void test_call3(int a[good()][good()])
#else
void test_call3(a)
int a[good()][good()];
#endif
{
}

void Fail(void) {
        printf ("Failed Conformance Test c23vla\n");
        exit(0);
}

int main(void) {
        int n;
        void *p;
        
        // Test VLAs as function parameters

        static int a[4][3][2], b[10][20][2];
        
        set_vla(4, 3, 2, a);
        for (int i = 0; i < 4; i++) {
                for (int j = 0; j < 3; j++) {
                        for (int k = 0; k < 2; k++) {
                                if (a[i][j][k] != i*100 + j*10 + k)
                                        Fail();
                        }
                }
        }

        set_vla(10, 20, 2, b);
        for (int i = 0; i < 10; i++) {
                for (int j = 0; j < 20; j++) {
                        for (int k = 0; k < 2; k++) {
                                if (b[i][j][k] != i*100 + j*10 + k)
                                        Fail();
                        }
                }
        }

        // Test circumstances where size expressions are evaluated
        
        int (*c)[good()];
        expected_good_count++;
        
        test_call1(NULL);
        expected_good_count++;
        
        test_call2(NULL);
        expected_good_count += 3;
        
        test_call3(NULL);
        expected_good_count += 2;
        
        n = sizeof(int[good()]);
        expected_good_count++;
        
#if __STDC_VERSION__ >= 202311L
        sizeof(typeof(char[good()]));
        expected_good_count++;
#endif

        n = sizeof(char(*[good()])[optional()]);
        expected_good_count++;

        p = (int(*)[good()])NULL;
        expected_good_count++;
        
        p = (int(*)[good()]){NULL};
        expected_good_count++;

        if (good_count != expected_good_count)
                Fail();
        if (bad_count != 0)
                Fail();

        int (*d)[good()][good()] = malloc(sizeof(int[good()][good()]));
        expected_good_count += 4;
        if (d == NULL)
                Fail();

        n = sizeof((*d)[good()-1]);
        expected_good_count++;

#if __STDC_VERSION__ >= 202311L
        n = sizeof(typeof((*d)[good()-1]));
        expected_good_count++;
#endif

        typedef int A[good()];
        expected_good_count++;

        n = (1 && sizeof(int[good()]));
        expected_good_count++;

        // Test circumstances where size expressions are not evaluated

        extern int f(int q, int a[q + bad()]);
        
        n = sizeof(int(*)[bad()]);
        
        n = alignof(int[bad()]);
        
        char alignas(int[bad()]) x;
        
        n = (0 && sizeof(int[bad()]));
        
        // Test composite type rules
        
        if (sizeof(*(1 ? (int(*)[])0 : (A*)0)) != sizeof(A))
                Fail();

#if __STDC_VERSION__ >= 202311L
        p = (typeof(*(1 ? (int(*)[GOOD_VALUE])0 : (A*)0))){1,2,3};
#endif

        if (good_count != expected_good_count)
                Fail();
        if (bad_count != 0)
                Fail();

        printf("optional_count = %d\n", optional_count);

        printf ("Passed Conformance Test c23vla\n");
        return 0;
}
