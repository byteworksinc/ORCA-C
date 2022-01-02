/*
 * Test locale-related functions, including C99 additions.
 *
 * This does not test for the availability of any specific locales
 * other than "C" and "".
 */

#include <limits.h>
#include <locale.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {

        /* query locale */
        if (setlocale(LC_ALL, NULL) == NULL)
                goto Fail;

        /* set part or all of locale to "native environment" */
        if (setlocale(LC_COLLATE, "") == NULL)
                goto Fail;
        if (setlocale(LC_CTYPE, "") == NULL)
                goto Fail;
        if (setlocale(LC_MONETARY, "") == NULL)
                goto Fail;
        if (setlocale(LC_NUMERIC, "") == NULL)
                goto Fail;
        if (setlocale(LC_TIME, "") == NULL)
                goto Fail;
        if (setlocale(LC_ALL, "") == NULL)
                goto Fail;

        /* setting a (presumably) invalid locale should fail */
        if (setlocale(LC_ALL, "3454atfhjk-dfghfdkljglksjrh0;rdgfdsg") != NULL)
                goto Fail;

        /* set part or all of locale to C locale */
        if (setlocale(LC_COLLATE, "C") == NULL)
                goto Fail;
        if (setlocale(LC_CTYPE, "C") == NULL)
                goto Fail;
        if (setlocale(LC_MONETARY, "C") == NULL)
                goto Fail;
        if (setlocale(LC_NUMERIC, "C") == NULL)
                goto Fail;
        if (setlocale(LC_TIME, "C") == NULL)
                goto Fail;
        if (setlocale(LC_ALL, "C") == NULL)
                goto Fail;
        
        /* test localeconv() output in "C" locale */
        struct lconv *lc = localeconv();
        if (       strcmp(lc->decimal_point, ".")
                || strcmp(lc->thousands_sep, "")
                || strcmp(lc->grouping, "")
                || strcmp(lc->mon_decimal_point, "")
                || strcmp(lc->mon_thousands_sep, "")
                || strcmp(lc->mon_grouping, "")
                || strcmp(lc->positive_sign, "")
                || strcmp(lc->negative_sign, "")
                || strcmp(lc->currency_symbol, "")
                || lc->frac_digits != CHAR_MAX
                || lc->p_cs_precedes != CHAR_MAX
                || lc->n_cs_precedes != CHAR_MAX
                || lc->p_sep_by_space != CHAR_MAX
                || lc->n_sep_by_space != CHAR_MAX
                || lc->p_sign_posn != CHAR_MAX
                || lc->n_sign_posn != CHAR_MAX
                || strcmp(lc->int_curr_symbol, "")
                || lc->int_frac_digits != CHAR_MAX
                || lc->int_p_cs_precedes != CHAR_MAX
                || lc->int_n_cs_precedes != CHAR_MAX
                || lc->int_p_sep_by_space != CHAR_MAX
                || lc->int_n_sep_by_space != CHAR_MAX
                || lc->int_p_sign_posn != CHAR_MAX
                || lc->int_n_sign_posn != CHAR_MAX)
                goto Fail;

        /* test strcoll in "C" locale */
        if (strcoll("abd", "acd") >= 0)
                goto Fail;
        if (strcoll("abc", "abc") != 0)
                goto Fail;
        if (strcoll("124", "123") <= 0)
                goto Fail;
        
        /* test strxfrm */
        char buf1[50] = {0}, buf2[50] = {0};
        if (strxfrm(buf1, "abd", sizeof buf1) >= sizeof buf1)
                goto Fail;
        if (strxfrm(buf2, "acd", sizeof buf2) >= sizeof buf2)
                goto Fail;
        if (strcmp(buf1, buf2) >= 0)
                goto Fail;

        /* test mblen */
        if (mblen("", 1) != 0)
                goto Fail;
        if (mblen("xyz", 3) != 1)
                goto Fail;
        mblen(NULL, 0);

        printf ("Passed Conformance Test c99locale\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99locale\n");
}
