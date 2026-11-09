/* Focused test of signed char lvalue conversion through indirect access. */

#include <stdio.h>

struct record {
        signed char c;
};

int main(void) {
        signed char array[1] = {0};
        struct record records[1] = {{0}};
        struct record *recordPointer = records;
        signed char value = 0;
        signed char *pointer = &value;
        int i = 0;

        if (array[i] != 0 || !(array[i] == 0) || (array[i] ? 1 : 0) != 0)
                goto Fail;
        if (records[i].c != 0 || recordPointer->c != 0)
                goto Fail;
        if (*pointer != 0 || (*pointer ? 1 : 0) != 0)
                goto Fail;

        printf("Passed Conformance Test 3.2.2.1\n");
        return 0;

Fail:
        printf("Failed Conformance Test 3.2.2.1\n");
        return 1;
}