/*
 * Test <stdarg.h> functionality, including va_copy (from C99).
 */

#include <stdarg.h>
#include <stdio.h>

int va_list_fn(va_list ap) {
        va_list ap2;

        /* Test use of va_copy in a function that was passed a va_list */
        va_copy(ap2, ap);

        if (va_arg(ap2, double) != 67890.0)
                return 0;
        
        if (va_arg(ap2, long) != 1234567890)
                return 0;
        
        va_end(ap2);
        
        return 1;
}

int va_fn(int x, ...) {
        va_list ap, ap2;
        int i, *ip = &i;

        /* Test basic varargs functionality */
        va_start(ap, x);

        if (va_arg(ap, int) != 12345)
                return 0;

        /* Test va_copy */
        va_copy(ap2, ap);

        if (va_arg(ap2, double) != 67890.0)
                return 0;
        
        /* Test passing a va_list to another function */
        if (!va_list_fn(ap))
                return 0;
        
        va_end(ap);
        va_end(ap2);
        
        /* Test that varargs processing can be restarted */
        va_start(ap, x);
        if (va_arg(ap, int) != 12345)
                return 0;
        va_end(ap);
        
        /* Test that va_end does not change local variable addresses */
        if (&i != ip)
                return 0;
        
        return 1;
}

int main(void) {

        if (!va_fn(1, 12345, 67890.0, 1234567890L))
                goto Fail;

        printf ("Passed Conformance Test c99stdarg\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99stdarg\n");
}
