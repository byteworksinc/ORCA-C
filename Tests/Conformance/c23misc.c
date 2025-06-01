/*
 * Test miscellaneous C23 features.
 */

#include <stdio.h>

int main(void) {
        //labels not preceding a statement
        {
                foo: int i;
                bar:
        }
}
