/* Deviance Test 7.8.0.1:  Ensure invalid operand types for ?: are detected */

int printf(const char *, ...);

int main(void) {
        int i = 1;
        struct S {int i;} s = {4};
        int *ip = &i;
        long *lp = 0;
        const int *cip = &i;

        /* each statement below should give an error */
        1 ? i : s;
        1 ? s : i;
        1 ? i : (void)0;
        1 ? ip : lp;
        
        /* these are illegal in standard C, but allowed by loose type checks */
#pragma ignore 24
        1 ? main : (void*)(void*)0;
        1 ? &ip : &cip;
        
        /* should give an error, but currently does not in ORCA/C */
        1 ? cip : (char)+0.0;
        
        printf ("Failed Deviance Test 7.8.0.1\n");
}
