/*
 * Test _Pragma preprocessing operator (C99).
 */

#include <stdio.h>

#pragma optimize -1
#pragma debug -1

_Pragma("debug 0")

#define p(x) _Pragma(#x)
#define opt(x) p(optimize x)

void f(int n, ...) {
}

opt(1+2)

int _Pragma("")main(_Pragma("*#^abcdefg foo bar baz")void) {
        f(123, 456, 789);
        printf _Pragma("unrecognized")("Passed Conformance Test c99pragma\n");
}
