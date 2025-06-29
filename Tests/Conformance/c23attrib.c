/*
 * Test attributes (C23).
 */

#include <stdio.h>

#if __has_c_attribute(fallthrough) < 0 || __has_c_attribute(_Noreturn) < 0
#error "__has_c_attribute error"
#endif

#if __has_c_attribute(nonexistent_attr) || __has_c_attribute(nonexistent::do)
#error "__has_c_attribute error"
#endif

#ifndef __has_c_attribute
#error "__has_c_attribute error"
#endif

[[]]int a = 1;

static long [[]] b;

[[]];

struct [[]] S;

struct [[nodiscard]] S {
        [[maybe_unused]] int a;
        char [[]] b;
};

enum [[]] E {
        x [[]],
        y [[]] = 100,
        z,
};

int c [[]], d[12] [[]], *e [[]];

int * [[]] volatile * [[]] f;

int g([[]] int a, [[]] int b[10] [[]], int (*c)() [[]]) [[]];

[[deprecated,noreturn,_Noreturn]] void h();

int i(void *) [[__unsequenced__,reproducible,]] [[unsequenced,unsequenced,]];

[[]] int main(void) {
        [[]] {}
        [[]] if (1)
                [[]] goto lab;

        [[]] int x;
        
        [[foo::bar([2.3{1;"x"}]r), foo::baz]];

[[]] lab:
        switch (a) {
        [[]] case 1:
                ;
                [[fallthrough]];
        [[]] default:
                ;
        }
        
        [[]] a = a+1;

        printf ("Passed Conformance Test c23attrib\n");
        return 0;
}
