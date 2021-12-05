/*
 * Test Unicode characters and strings (C11).
 */

#include <stdio.h>
#include <uchar.h>

#if !__STDC_UTF_16__ || !__STDC_UTF_32__
#error "Compiler does not use UTF-16/UTF-32 encodings"
#endif

int main(void) {
        char16_t c16 = u'a';
        char32_t c32 = U'A';
        
        if (c16 != 0x61)
                goto Fail;
        if (c32 != 0x41)
                goto Fail;
        
        c16 = u'\u283C';
        c32 = U'\uFB76';
        
        if (c16 != 0x283C)
                goto Fail;
        if (c32 != 0xFB76)
                goto Fail;
        
        c32 = U'\U0002B820';
        
        if (c32 != 0x2B820)
                goto Fail;
        
        char s8[] = u8"a\u042D\uF910\U00010085";
        unsigned char *s8u = (unsigned char*)s8;
        
        if (sizeof s8 != 11)
                goto Fail;
                
        if (s8u[0] != 0x61 || s8u[1] != 0xd0 || s8u[2] != 0xad || 
            s8u[3] != 0xef || s8u[4] != 0xa4 || s8u[5] != 0x90 || 
            s8u[6] != 0xf0 || s8u[7] != 0x90 || s8u[8] != 0x82 || 
            s8u[9] != 0x85 || s8u[10] != 0x00)
                goto Fail;
        
        char16_t s16[] = u"a\u042D\uF910\U00010085";
        
        if (sizeof s16 != 6 * sizeof(char16_t))
                goto Fail;
        
        if (s16[0] != 0x0061 || s16[1] != 0x042d || s16[2] != 0xf910 ||
            s16[3] != 0xd800 || s16[4] != 0xdc85 || s16[5] != 0x0000)
                goto Fail;
        
        char32_t s32[] = U"a\u042D\uF910\U00010085";
        
        if (sizeof s32 != 5 * sizeof(char32_t))
                goto Fail;
        
        if (s32[0] != 0x000061 || s32[1] != 0x00042d || s32[2] != 0x00f910 ||
            s32[3] != 0x010085 || s32[4] != 0x000000)
                goto Fail;
        
        printf ("Passed Conformance Test c99unicode\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c99unicode\n");
}
