/*
 * Test use of generic selection expressions (C11).
 */

#include <stdio.h>

#define g(x) _Generic((x),      \
        int: (x)+1,             \
        long: (x)+2,            \
        double: (x)+3,          \
        long double: (x)+4,     \
        unsigned char *: 100,   \
        int *: 101,             \
        default: 200            \
        )

int i = 0;

#define check_expression_type(T) _Generic((T)i, T: 1)
#define check_constant_type(T)   _Generic((T)0, T: 1)

int main(void) {
        if (g(12345) != 12346)
                goto Fail;

        if (g(1000000L) != 1000002)
                goto Fail;

        if (g(123.0) != 126.0)
                goto Fail;

        if (g(123.0L) != 127.0L)
                goto Fail;

        if (g((unsigned char*)&i) != 100)
                goto Fail;

        if (g(&i) != 101)
                goto Fail;

        if (g(123u) != 200)
                goto Fail;

        check_expression_type(_Bool);
        check_expression_type(char);
        check_expression_type(signed char);
        check_expression_type(unsigned char);
        check_expression_type(short);
        check_expression_type(unsigned short);
        check_expression_type(int);
        check_expression_type(unsigned int);
        check_expression_type(long);
        check_expression_type(unsigned long);
        check_expression_type(long long);
        check_expression_type(unsigned long long);
        check_expression_type(float);
        check_expression_type(double);
        check_expression_type(long double);

        check_constant_type(_Bool);
        check_constant_type(char);
        check_constant_type(signed char);
        check_constant_type(unsigned char);
        check_constant_type(short);
        check_constant_type(unsigned short);
        check_constant_type(int);
        check_constant_type(unsigned int);
        check_constant_type(long);
        check_constant_type(unsigned long);
        check_constant_type(long long);
        check_constant_type(unsigned long long);
        check_constant_type(float);
        check_constant_type(double);
        check_constant_type(long double);
        check_constant_type(void*);

        printf ("Passed Conformance Test c11generic\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c11generic\n");
}
