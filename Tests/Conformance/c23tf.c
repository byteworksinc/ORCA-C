/*
 * Test true and false keywords (C23).
 *
 * This will only work in a C23 language mode.
 */

#include <stdio.h>

#if __STDC_VERSION__ < 202311L
#error This is not expected to work in pre-C23 language versions.
#endif

bool a = true, b = false;

int main(void) {
        if (a != 1 || b != 0)
                goto Fail;

        if (true + true + false + 15 != 17)
                goto Fail;

        _Generic(true, bool: 1);
        _Generic(false, bool: 1);
        _Generic(+true, int: 1);

#if true != 1
#error true should be 1 in the preprocessor
#endif
#if false != 0
#error false should be 0 in the preprocessor
#endif

        printf ("Passed Conformance Test c23tf\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23tf\n");
}
