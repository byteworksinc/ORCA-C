/*
 * Test support for digraphs (C95).
 */

%:include <stdio.h>

#define merge(a,b) a%:%:b

int main(void) <%
        merge(in,t) a<:1] = {123%>;

        if (a[0:> != 123)
                goto Fail;

        printf ("Passed Conformance Test c95digraph\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c95digraph\n");
}
