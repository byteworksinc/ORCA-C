/*
 * Test _BitInt types (C23).
 */

#include <stdio.h>
#include <limits.h>

#define assert_type(e,t) (void)_Generic((e), t:(e))
#define assert_type_val(e,t,v) if (_Generic((e), t:(e)) != (v)) goto Fail

#define assert_compound_type(t1,t2,t3) (_Generic((t1)0 & (t2)0, t3:0) + _Generic((t1)x & (t2)y, t3:0))

unsigned _BitInt(1) x,y;

unsigned _BitInt(12) gu12 = 0xffffffffffff;
unsigned _BitInt(28) gu28 = 0xffffffffffff;

unsigned long long gull = (unsigned _BitInt(52))0xabcdef0123456789;

struct S {
        unsigned _BitInt(1) : 1;
        _BitInt(31) f1 : 24;
        _BitInt(12) : 2;
        _BitInt(14) f2 : 8;
} s = {0x123456, 0x78};

unsigned _BitInt(64) u24fn(unsigned _BitInt(24) x) {
        return x;
}

unsigned _BitInt(24) u64fn(unsigned _BitInt(64) x) {
        return x;
}

int main(void) {
        _BitInt(2)  s2  = -1;
        _BitInt(15) s15 = -1;
        _BitInt(16) s16 = -1;
        _BitInt(17) s17 = -1;
        _BitInt(31) s31 = -1;
        _BitInt(32) s32 = -1;
        _BitInt(33) s33 = -1;
        _BitInt(47) s47 = -1;
        _BitInt(48) s48 = -1;
        _BitInt(49) s49 = -1;
        _BitInt(63) s63 = -1;
        _BitInt(64) s64 = -1;

        unsigned _BitInt(1)  u1  = s2;
        unsigned _BitInt(15) u15 = s2;
        unsigned _BitInt(16) u16 = s2;
        unsigned _BitInt(17) u17 = s2;
        unsigned _BitInt(31) u31 = s2;
        unsigned _BitInt(32) u32 = s2;
        unsigned _BitInt(33) u33 = s2;
        unsigned _BitInt(47) u47 = s2;
        unsigned _BitInt(48) u48 = s2;
        unsigned _BitInt(49) u49 = s2;
        unsigned _BitInt(63) u63 = s2;
        unsigned _BitInt(64) u64 = s2;

        _BitInt(1)  unsigned *u1p  = &u1;
        _BitInt(15) unsigned *u15p = &u15;
        _BitInt(16) unsigned *u16p = &u16;
        _BitInt(17) unsigned *u17p = &u17;
        _BitInt(31) unsigned *u31p = &u31;
        _BitInt(32) unsigned *u32p = &u32;
        _BitInt(33) unsigned *u33p = &u33;
        _BitInt(47) unsigned *u47p = &u47;
        _BitInt(48) unsigned *u48p = &u48;
        _BitInt(49) unsigned *u49p = &u49;
        _BitInt(63) unsigned *u63p = &u63;
        _BitInt(64) unsigned *u64p = &u64;

        if (BITINT_MAXWIDTH < 64)
                goto Fail;

        assert_type_val(gu12, unsigned _BitInt(12), 0xfff);
        assert_type_val(gu28, unsigned _BitInt(28), 0xfffffff);
        assert_type_val(gull, unsigned long long, 0xdef0123456789);

        assert_type_val(u24fn(0xffffffffffff), unsigned _BitInt(64), 0xffffff);
        assert_type_val(u64fn(0xffffffffffff), unsigned _BitInt(24), 0xffffff);

        if (s.f1 != 0x123456)
                goto Fail;
        if (s.f2 != 0x78)
                goto Fail;

#ifdef __ORCAC__
        _Static_assert(sizeof(_BitInt(2)) == 2);
        _Static_assert(sizeof(_BitInt(15)) == 2);
        _Static_assert(sizeof(_BitInt(16)) == 2);
        _Static_assert(sizeof(_BitInt(17)) == 4);
        _Static_assert(sizeof(_BitInt(31)) == 4);
        _Static_assert(sizeof(_BitInt(32)) == 4);
        _Static_assert(sizeof(_BitInt(33)) == 8);
        _Static_assert(sizeof(_BitInt(47)) == 8);
        _Static_assert(sizeof(_BitInt(48)) == 8);
        _Static_assert(sizeof(_BitInt(49)) == 8);
        _Static_assert(sizeof(_BitInt(63)) == 8);
        _Static_assert(sizeof(_BitInt(64)) == 8);

        _Static_assert(sizeof(s2) == 2);
        _Static_assert(sizeof(s15) == 2);
        _Static_assert(sizeof(s16) == 2);
        _Static_assert(sizeof(s17) == 4);
        _Static_assert(sizeof(s31) == 4);
        _Static_assert(sizeof(s32) == 4);
        _Static_assert(sizeof(s33) == 8);
        _Static_assert(sizeof(s47) == 8);
        _Static_assert(sizeof(s48) == 8);
        _Static_assert(sizeof(s49) == 8);
        _Static_assert(sizeof(s63) == 8);
        _Static_assert(sizeof(s64) == 8);

        _Static_assert(sizeof(unsigned _BitInt(1)) == 2);
        _Static_assert(sizeof(unsigned _BitInt(15)) == 2);
        _Static_assert(sizeof(unsigned _BitInt(16)) == 2);
        _Static_assert(sizeof(unsigned _BitInt(17)) == 4);
        _Static_assert(sizeof(unsigned _BitInt(31)) == 4);
        _Static_assert(sizeof(unsigned _BitInt(32)) == 4);
        _Static_assert(sizeof(unsigned _BitInt(33)) == 8);
        _Static_assert(sizeof(unsigned _BitInt(47)) == 8);
        _Static_assert(sizeof(unsigned _BitInt(48)) == 8);
        _Static_assert(sizeof(unsigned _BitInt(49)) == 8);
        _Static_assert(sizeof(unsigned _BitInt(63)) == 8);
        _Static_assert(sizeof(unsigned _BitInt(64)) == 8);

        _Static_assert(sizeof(u1) == 2);
        _Static_assert(sizeof(u15) == 2);
        _Static_assert(sizeof(u16) == 2);
        _Static_assert(sizeof(u17) == 4);
        _Static_assert(sizeof(u31) == 4);
        _Static_assert(sizeof(u32) == 4);
        _Static_assert(sizeof(u33) == 8);
        _Static_assert(sizeof(u47) == 8);
        _Static_assert(sizeof(u48) == 8);
        _Static_assert(sizeof(u49) == 8);
        _Static_assert(sizeof(u63) == 8);
        _Static_assert(sizeof(u64) == 8);
#endif

        assert_type_val(s2,  _BitInt(2),  -1);
        assert_type_val(s15, _BitInt(15), -1);
        assert_type_val(s16, _BitInt(16), -1);
        assert_type_val(s17, _BitInt(17), -1);
        assert_type_val(s31, _BitInt(31), -1);
        assert_type_val(s32, _BitInt(32), -1);
        assert_type_val(s33, _BitInt(33), -1);
        assert_type_val(s47, _BitInt(47), -1);
        assert_type_val(s48, _BitInt(48), -1);
        assert_type_val(s63, _BitInt(63), -1);
        assert_type_val(s64, _BitInt(64), -1);

        assert_type_val(u1,  unsigned _BitInt(1),  0x1);
        assert_type_val(u15, unsigned _BitInt(15), 0x7fff);
        assert_type_val(u16, unsigned _BitInt(16), 0xffff);
        assert_type_val(u17, unsigned _BitInt(17), 0x1ffff);
        assert_type_val(u31, unsigned _BitInt(31), 0x7fffffff);
        assert_type_val(u32, unsigned _BitInt(32), 0xffffffff);
        assert_type_val(u33, unsigned _BitInt(33), 0x1ffffffff);
        assert_type_val(u47, unsigned _BitInt(47), 0x7fffffffffff);
        assert_type_val(u48, unsigned _BitInt(48), 0xffffffffffff);
        assert_type_val(u63, unsigned _BitInt(63), 0x7fffffffffffffff);
        assert_type_val(u64, unsigned _BitInt(64), 0xffffffffffffffff);

        assert_type_val(+s2,  _BitInt(2),  -1);
        assert_type_val(+s15, _BitInt(15), -1);
        assert_type_val(+s16, _BitInt(16), -1);
        assert_type_val(+s17, _BitInt(17), -1);
        assert_type_val(+s31, _BitInt(31), -1);
        assert_type_val(+s32, _BitInt(32), -1);
        assert_type_val(+s33, _BitInt(33), -1);
        assert_type_val(+s47, _BitInt(47), -1);
        assert_type_val(+s48, _BitInt(48), -1);
        assert_type_val(+s63, _BitInt(63), -1);
        assert_type_val(+s64, _BitInt(64), -1);

        assert_type_val(+u1,  unsigned _BitInt(1),  0x1);
        assert_type_val(+u15, unsigned _BitInt(15), 0x7fff);
        assert_type_val(+u16, unsigned _BitInt(16), 0xffff);
        assert_type_val(+u17, unsigned _BitInt(17), 0x1ffff);
        assert_type_val(+u31, unsigned _BitInt(31), 0x7fffffff);
        assert_type_val(+u32, unsigned _BitInt(32), 0xffffffff);
        assert_type_val(+u33, unsigned _BitInt(33), 0x1ffffffff);
        assert_type_val(+u47, unsigned _BitInt(47), 0x7fffffffffff);
        assert_type_val(+u48, unsigned _BitInt(48), 0xffffffffffff);
        assert_type_val(+u63, unsigned _BitInt(63), 0x7fffffffffffffff);
        assert_type_val(+u64, unsigned _BitInt(64), 0xffffffffffffffff);

        assert_type_val(-s2,  _BitInt(2),  1);
        assert_type_val(-s15, _BitInt(15), 1);
        assert_type_val(-s16, _BitInt(16), 1);
        assert_type_val(-s17, _BitInt(17), 1);
        assert_type_val(-s31, _BitInt(31), 1);
        assert_type_val(-s32, _BitInt(32), 1);
        assert_type_val(-s33, _BitInt(33), 1);
        assert_type_val(-s47, _BitInt(47), 1);
        assert_type_val(-s48, _BitInt(48), 1);
        assert_type_val(-s63, _BitInt(63), 1);
        assert_type_val(-s64, _BitInt(64), 1);

        assert_type_val(-u1,  unsigned _BitInt(1),  1);
        assert_type_val(-u15, unsigned _BitInt(15), 1);
        assert_type_val(-u16, unsigned _BitInt(16), 1);
        assert_type_val(-u17, unsigned _BitInt(17), 1);
        assert_type_val(-u31, unsigned _BitInt(31), 1);
        assert_type_val(-u32, unsigned _BitInt(32), 1);
        assert_type_val(-u33, unsigned _BitInt(33), 1);
        assert_type_val(-u47, unsigned _BitInt(47), 1);
        assert_type_val(-u48, unsigned _BitInt(48), 1);
        assert_type_val(-u63, unsigned _BitInt(63), 1);
        assert_type_val(-u64, unsigned _BitInt(64), 1);

        assert_type_val(~s2,  _BitInt(2),  0);
        assert_type_val(~s15, _BitInt(15), 0);
        assert_type_val(~s16, _BitInt(16), 0);
        assert_type_val(~s17, _BitInt(17), 0);
        assert_type_val(~s31, _BitInt(31), 0);
        assert_type_val(~s32, _BitInt(32), 0);
        assert_type_val(~s33, _BitInt(33), 0);
        assert_type_val(~s47, _BitInt(47), 0);
        assert_type_val(~s48, _BitInt(48), 0);
        assert_type_val(~s63, _BitInt(63), 0);
        assert_type_val(~s64, _BitInt(64), 0);

        assert_type_val(~u1,  unsigned _BitInt(1),  0);
        assert_type_val(~u15, unsigned _BitInt(15), 0);
        assert_type_val(~u16, unsigned _BitInt(16), 0);
        assert_type_val(~u17, unsigned _BitInt(17), 0);
        assert_type_val(~u31, unsigned _BitInt(31), 0);
        assert_type_val(~u32, unsigned _BitInt(32), 0);
        assert_type_val(~u33, unsigned _BitInt(33), 0);
        assert_type_val(~u47, unsigned _BitInt(47), 0);
        assert_type_val(~u48, unsigned _BitInt(48), 0);
        assert_type_val(~u63, unsigned _BitInt(63), 0);
        assert_type_val(~u64, unsigned _BitInt(64), 0);

        assert_type_val(!s2,  int, 0);
        assert_type_val(!s15, int, 0);
        assert_type_val(!s16, int, 0);
        assert_type_val(!s17, int, 0);
        assert_type_val(!s31, int, 0);
        assert_type_val(!s32, int, 0);
        assert_type_val(!s33, int, 0);
        assert_type_val(!s47, int, 0);
        assert_type_val(!s48, int, 0);
        assert_type_val(!s63, int, 0);
        assert_type_val(!s64, int, 0);

        assert_type_val(!u1,  int, 0);
        assert_type_val(!u15, int, 0);
        assert_type_val(!u16, int, 0);
        assert_type_val(!u17, int, 0);
        assert_type_val(!u31, int, 0);
        assert_type_val(!u32, int, 0);
        assert_type_val(!u33, int, 0);
        assert_type_val(!u47, int, 0);
        assert_type_val(!u48, int, 0);
        assert_type_val(!u63, int, 0);
        assert_type_val(!u64, int, 0);

        assert_type_val(++s2,  _BitInt(2),  0);
        assert_type_val(++s15, _BitInt(15), 0);
        assert_type_val(++s16, _BitInt(16), 0);
        assert_type_val(++s17, _BitInt(17), 0);
        assert_type_val(++s31, _BitInt(31), 0);
        assert_type_val(++s32, _BitInt(32), 0);
        assert_type_val(++s33, _BitInt(33), 0);
        assert_type_val(++s47, _BitInt(47), 0);
        assert_type_val(++s48, _BitInt(48), 0);
        assert_type_val(++s63, _BitInt(63), 0);
        assert_type_val(++s64, _BitInt(64), 0);

        assert_type_val(++u1,  unsigned _BitInt(1),  0);
        assert_type_val(++u15, unsigned _BitInt(15), 0);
        assert_type_val(++u16, unsigned _BitInt(16), 0);
        assert_type_val(++u17, unsigned _BitInt(17), 0);
        assert_type_val(++u31, unsigned _BitInt(31), 0);
        assert_type_val(++u32, unsigned _BitInt(32), 0);
        assert_type_val(++u33, unsigned _BitInt(33), 0);
        assert_type_val(++u47, unsigned _BitInt(47), 0);
        assert_type_val(++u48, unsigned _BitInt(48), 0);
        assert_type_val(++u63, unsigned _BitInt(63), 0);
        assert_type_val(++u64, unsigned _BitInt(64), 0);

        assert_type_val(--s2,  _BitInt(2),  -1);
        assert_type_val(--s15, _BitInt(15), -1);
        assert_type_val(--s16, _BitInt(16), -1);
        assert_type_val(--s17, _BitInt(17), -1);
        assert_type_val(--s31, _BitInt(31), -1);
        assert_type_val(--s32, _BitInt(32), -1);
        assert_type_val(--s33, _BitInt(33), -1);
        assert_type_val(--s47, _BitInt(47), -1);
        assert_type_val(--s48, _BitInt(48), -1);
        assert_type_val(--s63, _BitInt(63), -1);
        assert_type_val(--s64, _BitInt(64), -1);

        assert_type_val(--u1,  unsigned _BitInt(1),  0x1);
        assert_type_val(--u15, unsigned _BitInt(15), 0x7fff);
        assert_type_val(--u16, unsigned _BitInt(16), 0xffff);
        assert_type_val(--u17, unsigned _BitInt(17), 0x1ffff);
        assert_type_val(--u31, unsigned _BitInt(31), 0x7fffffff);
        assert_type_val(--u32, unsigned _BitInt(32), 0xffffffff);
        assert_type_val(--u33, unsigned _BitInt(33), 0x1ffffffff);
        assert_type_val(--u47, unsigned _BitInt(47), 0x7fffffffffff);
        assert_type_val(--u48, unsigned _BitInt(48), 0xffffffffffff);
        assert_type_val(--u63, unsigned _BitInt(63), 0x7fffffffffffffff);
        assert_type_val(--u64, unsigned _BitInt(64), 0xffffffffffffffff);

        assert_type_val(++(*u1p),  unsigned _BitInt(1),  0);
        assert_type_val(++(*u15p), unsigned _BitInt(15), 0);
        assert_type_val(++(*u16p), unsigned _BitInt(16), 0);
        assert_type_val(++(*u17p), unsigned _BitInt(17), 0);
        assert_type_val(++(*u31p), unsigned _BitInt(31), 0);
        assert_type_val(++(*u32p), unsigned _BitInt(32), 0);
        assert_type_val(++(*u33p), unsigned _BitInt(33), 0);
        assert_type_val(++(*u47p), unsigned _BitInt(47), 0);
        assert_type_val(++(*u48p), unsigned _BitInt(48), 0);
        assert_type_val(++(*u63p), unsigned _BitInt(63), 0);
        assert_type_val(++(*u64p), unsigned _BitInt(64), 0);

        assert_type_val(--(*u1p),  unsigned _BitInt(1),  0x1);
        assert_type_val(--(*u15p), unsigned _BitInt(15), 0x7fff);
        assert_type_val(--(*u16p), unsigned _BitInt(16), 0xffff);
        assert_type_val(--(*u17p), unsigned _BitInt(17), 0x1ffff);
        assert_type_val(--(*u31p), unsigned _BitInt(31), 0x7fffffff);
        assert_type_val(--(*u32p), unsigned _BitInt(32), 0xffffffff);
        assert_type_val(--(*u33p), unsigned _BitInt(33), 0x1ffffffff);
        assert_type_val(--(*u47p), unsigned _BitInt(47), 0x7fffffffffff);
        assert_type_val(--(*u48p), unsigned _BitInt(48), 0xffffffffffff);
        assert_type_val(--(*u63p), unsigned _BitInt(63), 0x7fffffffffffffff);
        assert_type_val(--(*u64p), unsigned _BitInt(64), 0xffffffffffffffff);

        assert_type_val(s2--,  _BitInt(2),  -1);
        assert_type_val(s15--, _BitInt(15), -1);
        assert_type_val(s16--, _BitInt(16), -1);
        assert_type_val(s17--, _BitInt(17), -1);
        assert_type_val(s31--, _BitInt(31), -1);
        assert_type_val(s32--, _BitInt(32), -1);
        assert_type_val(s33--, _BitInt(33), -1);
        assert_type_val(s47--, _BitInt(47), -1);
        assert_type_val(s48--, _BitInt(48), -1);
        assert_type_val(s63--, _BitInt(63), -1);
        assert_type_val(s64--, _BitInt(64), -1);

        assert_type_val(u1--,  unsigned _BitInt(1),  0x1);
        assert_type_val(u15--, unsigned _BitInt(15), 0x7fff);
        assert_type_val(u16--, unsigned _BitInt(16), 0xffff);
        assert_type_val(u17--, unsigned _BitInt(17), 0x1ffff);
        assert_type_val(u31--, unsigned _BitInt(31), 0x7fffffff);
        assert_type_val(u32--, unsigned _BitInt(32), 0xffffffff);
        assert_type_val(u33--, unsigned _BitInt(33), 0x1ffffffff);
        assert_type_val(u47--, unsigned _BitInt(47), 0x7fffffffffff);
        assert_type_val(u48--, unsigned _BitInt(48), 0xffffffffffff);
        assert_type_val(u63--, unsigned _BitInt(63), 0x7fffffffffffffff);
        assert_type_val(u64--, unsigned _BitInt(64), 0xffffffffffffffff);

        assert_type_val(s2++,  _BitInt(2),  -2);
        assert_type_val(s15++, _BitInt(15), -2);
        assert_type_val(s16++, _BitInt(16), -2);
        assert_type_val(s17++, _BitInt(17), -2);
        assert_type_val(s31++, _BitInt(31), -2);
        assert_type_val(s32++, _BitInt(32), -2);
        assert_type_val(s33++, _BitInt(33), -2);
        assert_type_val(s47++, _BitInt(47), -2);
        assert_type_val(s48++, _BitInt(48), -2);
        assert_type_val(s63++, _BitInt(63), -2);
        assert_type_val(s64++, _BitInt(64), -2);

        assert_type_val(u1++,  unsigned _BitInt(1),  0x0);
        assert_type_val(u15++, unsigned _BitInt(15), 0x7ffe);
        assert_type_val(u16++, unsigned _BitInt(16), 0xfffe);
        assert_type_val(u17++, unsigned _BitInt(17), 0x1fffe);
        assert_type_val(u31++, unsigned _BitInt(31), 0x7ffffffe);
        assert_type_val(u32++, unsigned _BitInt(32), 0xfffffffe);
        assert_type_val(u33++, unsigned _BitInt(33), 0x1fffffffe);
        assert_type_val(u47++, unsigned _BitInt(47), 0x7ffffffffffe);
        assert_type_val(u48++, unsigned _BitInt(48), 0xfffffffffffe);
        assert_type_val(u63++, unsigned _BitInt(63), 0x7ffffffffffffffe);
        assert_type_val(u64++, unsigned _BitInt(64), 0xfffffffffffffffe);

        assert_type_val((*u1p)--,  unsigned _BitInt(1),  0x1);
        assert_type_val((*u15p)--, unsigned _BitInt(15), 0x7fff);
        assert_type_val((*u16p)--, unsigned _BitInt(16), 0xffff);
        assert_type_val((*u17p)--, unsigned _BitInt(17), 0x1ffff);
        assert_type_val((*u31p)--, unsigned _BitInt(31), 0x7fffffff);
        assert_type_val((*u32p)--, unsigned _BitInt(32), 0xffffffff);
        assert_type_val((*u33p)--, unsigned _BitInt(33), 0x1ffffffff);
        assert_type_val((*u47p)--, unsigned _BitInt(47), 0x7fffffffffff);
        assert_type_val((*u48p)--, unsigned _BitInt(48), 0xffffffffffff);
        assert_type_val((*u63p)--, unsigned _BitInt(63), 0x7fffffffffffffff);
        assert_type_val((*u64p)--, unsigned _BitInt(64), 0xffffffffffffffff);

        assert_type_val((*u1p)++,  unsigned _BitInt(1),  0x0);
        assert_type_val((*u15p)++, unsigned _BitInt(15), 0x7ffe);
        assert_type_val((*u16p)++, unsigned _BitInt(16), 0xfffe);
        assert_type_val((*u17p)++, unsigned _BitInt(17), 0x1fffe);
        assert_type_val((*u31p)++, unsigned _BitInt(31), 0x7ffffffe);
        assert_type_val((*u32p)++, unsigned _BitInt(32), 0xfffffffe);
        assert_type_val((*u33p)++, unsigned _BitInt(33), 0x1fffffffe);
        assert_type_val((*u47p)++, unsigned _BitInt(47), 0x7ffffffffffe);
        assert_type_val((*u48p)++, unsigned _BitInt(48), 0xfffffffffffe);
        assert_type_val((*u63p)++, unsigned _BitInt(63), 0x7ffffffffffffffe);
        assert_type_val((*u64p)++, unsigned _BitInt(64), 0xfffffffffffffffe);

        assert_type_val(s2  + s2,  _BitInt(2),  -2);
        assert_type_val(s15 + s15, _BitInt(15), -2);
        assert_type_val(s16 + s16, _BitInt(16), -2);
        assert_type_val(s17 + s17, _BitInt(17), -2);
        assert_type_val(s31 + s31, _BitInt(31), -2);
        assert_type_val(s32 + s32, _BitInt(32), -2);
        assert_type_val(s33 + s33, _BitInt(33), -2);
        assert_type_val(s47 + s47, _BitInt(47), -2);
        assert_type_val(s48 + s48, _BitInt(48), -2);
        assert_type_val(s63 + s63, _BitInt(63), -2);
        assert_type_val(s64 + s64, _BitInt(64), -2);

        assert_type_val(u1  + u1,  unsigned _BitInt(1),  0x0);
        assert_type_val(u15 + u15, unsigned _BitInt(15), 0x7ffe);
        assert_type_val(u16 + u16, unsigned _BitInt(16), 0xfffe);
        assert_type_val(u17 + u17, unsigned _BitInt(17), 0x1fffe);
        assert_type_val(u31 + u31, unsigned _BitInt(31), 0x7ffffffe);
        assert_type_val(u32 + u32, unsigned _BitInt(32), 0xfffffffe);
        assert_type_val(u33 + u33, unsigned _BitInt(33), 0x1fffffffe);
        assert_type_val(u47 + u47, unsigned _BitInt(47), 0x7ffffffffffe);
        assert_type_val(u48 + u48, unsigned _BitInt(48), 0xfffffffffffe);
        assert_type_val(u63 + u63, unsigned _BitInt(63), 0x7ffffffffffffffe);
        assert_type_val(u64 + u64, unsigned _BitInt(64), 0xfffffffffffffffe);

        assert_type_val(u1  + s2,  _BitInt(2),           0x0);
        assert_type_val(u15 + s15, unsigned _BitInt(15), 0x7ffe);
        assert_type_val(u16 + s16, unsigned _BitInt(16), 0xfffe);
        assert_type_val(u17 + s17, unsigned _BitInt(17), 0x1fffe);
        assert_type_val(u31 + s31, unsigned _BitInt(31), 0x7ffffffe);
        assert_type_val(u32 + s32, unsigned _BitInt(32), 0xfffffffe);
        assert_type_val(u33 + s33, unsigned _BitInt(33), 0x1fffffffe);
        assert_type_val(u47 + s47, unsigned _BitInt(47), 0x7ffffffffffe);
        assert_type_val(u48 + s48, unsigned _BitInt(48), 0xfffffffffffe);
        assert_type_val(u63 + s63, unsigned _BitInt(63), 0x7ffffffffffffffe);
        assert_type_val(u64 + s64, unsigned _BitInt(64), 0xfffffffffffffffe);

        assert_type_val(s2  - s2,  _BitInt(2),  0);
        assert_type_val(s15 - s15, _BitInt(15), 0);
        assert_type_val(s16 - s16, _BitInt(16), 0);
        assert_type_val(s17 - s17, _BitInt(17), 0);
        assert_type_val(s31 - s31, _BitInt(31), 0);
        assert_type_val(s32 - s32, _BitInt(32), 0);
        assert_type_val(s33 - s33, _BitInt(33), 0);
        assert_type_val(s47 - s47, _BitInt(47), 0);
        assert_type_val(s48 - s48, _BitInt(48), 0);
        assert_type_val(s63 - s63, _BitInt(63), 0);
        assert_type_val(s64 - s64, _BitInt(64), 0);

        assert_type_val(u1  - u1,  unsigned _BitInt(1),  0);
        assert_type_val(u15 - u15, unsigned _BitInt(15), 0);
        assert_type_val(u16 - u16, unsigned _BitInt(16), 0);
        assert_type_val(u17 - u17, unsigned _BitInt(17), 0);
        assert_type_val(u31 - u31, unsigned _BitInt(31), 0);
        assert_type_val(u32 - u32, unsigned _BitInt(32), 0);
        assert_type_val(u33 - u33, unsigned _BitInt(33), 0);
        assert_type_val(u47 - u47, unsigned _BitInt(47), 0);
        assert_type_val(u48 - u48, unsigned _BitInt(48), 0);
        assert_type_val(u63 - u63, unsigned _BitInt(63), 0);
        assert_type_val(u64 - u64, unsigned _BitInt(64), 0);

        assert_type_val(s2  * s2,  _BitInt(2),  1);
        assert_type_val(s15 * s15, _BitInt(15), 1);
        assert_type_val(s16 * s16, _BitInt(16), 1);
        assert_type_val(s17 * s17, _BitInt(17), 1);
        assert_type_val(s31 * s31, _BitInt(31), 1);
        assert_type_val(s32 * s32, _BitInt(32), 1);
        assert_type_val(s33 * s33, _BitInt(33), 1);
        assert_type_val(s47 * s47, _BitInt(47), 1);
        assert_type_val(s48 * s48, _BitInt(48), 1);
        assert_type_val(s63 * s63, _BitInt(63), 1);
        assert_type_val(s64 * s64, _BitInt(64), 1);

        assert_type_val(u1  * u1,  unsigned _BitInt(1),  1);
        assert_type_val(u15 * u15, unsigned _BitInt(15), 1);
        assert_type_val(u16 * u16, unsigned _BitInt(16), 1);
        assert_type_val(u17 * u17, unsigned _BitInt(17), 1);
        assert_type_val(u31 * u31, unsigned _BitInt(31), 1);
        assert_type_val(u32 * u32, unsigned _BitInt(32), 1);
        assert_type_val(u33 * u33, unsigned _BitInt(33), 1);
        assert_type_val(u47 * u47, unsigned _BitInt(47), 1);
        assert_type_val(u48 * u48, unsigned _BitInt(48), 1);
        assert_type_val(u63 * u63, unsigned _BitInt(63), 1);
        assert_type_val(u64 * u64, unsigned _BitInt(64), 1);

        assert_type_val(s2  / s2,  _BitInt(2),  1);
        assert_type_val(s15 / s15, _BitInt(15), 1);
        assert_type_val(s16 / s16, _BitInt(16), 1);
        assert_type_val(s17 / s17, _BitInt(17), 1);
        assert_type_val(s31 / s31, _BitInt(31), 1);
        assert_type_val(s32 / s32, _BitInt(32), 1);
        assert_type_val(s33 / s33, _BitInt(33), 1);
        assert_type_val(s47 / s47, _BitInt(47), 1);
        assert_type_val(s48 / s48, _BitInt(48), 1);
        assert_type_val(s63 / s63, _BitInt(63), 1);
        assert_type_val(s64 / s64, _BitInt(64), 1);

        assert_type_val(u1  / u1,  unsigned _BitInt(1),  1);
        assert_type_val(u15 / u15, unsigned _BitInt(15), 1);
        assert_type_val(u16 / u16, unsigned _BitInt(16), 1);
        assert_type_val(u17 / u17, unsigned _BitInt(17), 1);
        assert_type_val(u31 / u31, unsigned _BitInt(31), 1);
        assert_type_val(u32 / u32, unsigned _BitInt(32), 1);
        assert_type_val(u33 / u33, unsigned _BitInt(33), 1);
        assert_type_val(u47 / u47, unsigned _BitInt(47), 1);
        assert_type_val(u48 / u48, unsigned _BitInt(48), 1);
        assert_type_val(u63 / u63, unsigned _BitInt(63), 1);
        assert_type_val(u64 / u64, unsigned _BitInt(64), 1);

        assert_type_val(s2  % s2,  _BitInt(2),  0);
        assert_type_val(s15 % s15, _BitInt(15), 0);
        assert_type_val(s16 % s16, _BitInt(16), 0);
        assert_type_val(s17 % s17, _BitInt(17), 0);
        assert_type_val(s31 % s31, _BitInt(31), 0);
        assert_type_val(s32 % s32, _BitInt(32), 0);
        assert_type_val(s33 % s33, _BitInt(33), 0);
        assert_type_val(s47 % s47, _BitInt(47), 0);
        assert_type_val(s48 % s48, _BitInt(48), 0);
        assert_type_val(s63 % s63, _BitInt(63), 0);
        assert_type_val(s64 % s64, _BitInt(64), 0);

        assert_type_val(u1  % u1,  unsigned _BitInt(1),  0);
        assert_type_val(u15 % u15, unsigned _BitInt(15), 0);
        assert_type_val(u16 % u16, unsigned _BitInt(16), 0);
        assert_type_val(u17 % u17, unsigned _BitInt(17), 0);
        assert_type_val(u31 % u31, unsigned _BitInt(31), 0);
        assert_type_val(u32 % u32, unsigned _BitInt(32), 0);
        assert_type_val(u33 % u33, unsigned _BitInt(33), 0);
        assert_type_val(u47 % u47, unsigned _BitInt(47), 0);
        assert_type_val(u48 % u48, unsigned _BitInt(48), 0);
        assert_type_val(u63 % u63, unsigned _BitInt(63), 0);
        assert_type_val(u64 % u64, unsigned _BitInt(64), 0);

        assert_type_val(u1  ^ u1,  unsigned _BitInt(1),  0);
        assert_type_val(u15 ^ s15, unsigned _BitInt(15), 0);
        assert_type_val(u16 ^ s16, unsigned _BitInt(16), 0);
        assert_type_val(u17 ^ s17, unsigned _BitInt(17), 0);
        assert_type_val(u31 ^ s31, unsigned _BitInt(31), 0);
        assert_type_val(u32 ^ s32, unsigned _BitInt(32), 0);
        assert_type_val(u33 ^ s33, unsigned _BitInt(33), 0);
        assert_type_val(u47 ^ s47, unsigned _BitInt(47), 0);
        assert_type_val(u48 ^ s48, unsigned _BitInt(48), 0);
        assert_type_val(u63 ^ s63, unsigned _BitInt(63), 0);
        assert_type_val(u64 ^ s64, unsigned _BitInt(64), 0);

        assert_type_val(u1  | u1,  unsigned _BitInt(1),  0x1);
        assert_type_val(s15 | u15, unsigned _BitInt(15), 0x7fff);
        assert_type_val(s16 | u16, unsigned _BitInt(16), 0xffff);
        assert_type_val(s17 | u17, unsigned _BitInt(17), 0x1ffff);
        assert_type_val(s31 | u31, unsigned _BitInt(31), 0x7fffffff);
        assert_type_val(s32 | u32, unsigned _BitInt(32), 0xffffffff);
        assert_type_val(s33 | u33, unsigned _BitInt(33), 0x1ffffffff);
        assert_type_val(s47 | u47, unsigned _BitInt(47), 0x7fffffffffff);
        assert_type_val(s48 | u48, unsigned _BitInt(48), 0xffffffffffff);
        assert_type_val(s63 | u63, unsigned _BitInt(63), 0x7fffffffffffffff);
        assert_type_val(s64 | u64, unsigned _BitInt(64), 0xffffffffffffffff);

        assert_type_val(u1  & u1,  unsigned _BitInt(1),  0x1);
        assert_type_val(s15 & u15, unsigned _BitInt(15), 0x7fff);
        assert_type_val(s16 & u16, unsigned _BitInt(16), 0xffff);
        assert_type_val(s17 & u17, unsigned _BitInt(17), 0x1ffff);
        assert_type_val(s31 & u31, unsigned _BitInt(31), 0x7fffffff);
        assert_type_val(s32 & u32, unsigned _BitInt(32), 0xffffffff);
        assert_type_val(s33 & u33, unsigned _BitInt(33), 0x1ffffffff);
        assert_type_val(s47 & u47, unsigned _BitInt(47), 0x7fffffffffff);
        assert_type_val(s48 & u48, unsigned _BitInt(48), 0xffffffffffff);
        assert_type_val(s63 & u63, unsigned _BitInt(63), 0x7fffffffffffffff);
        assert_type_val(s64 & u64, unsigned _BitInt(64), 0xffffffffffffffff);

        assert_type_val(u15 << 12, unsigned _BitInt(15), 0x7000);
        assert_type_val(u16 << 12, unsigned _BitInt(16), 0xf000);
        assert_type_val(u17 << 12, unsigned _BitInt(17), 0x1f000);
        assert_type_val(u31 << 12, unsigned _BitInt(31), 0x7ffff000);
        assert_type_val(u32 << 12, unsigned _BitInt(32), 0xfffff000);
        assert_type_val(u33 << 12, unsigned _BitInt(33), 0x1fffff000);
        assert_type_val(u47 << 12, unsigned _BitInt(47), 0x7ffffffff000);
        assert_type_val(u48 << 12, unsigned _BitInt(48), 0xfffffffff000);
        assert_type_val(u63 << 12, unsigned _BitInt(63), 0x7ffffffffffff000);
        assert_type_val(u64 << 12, unsigned _BitInt(64), 0xfffffffffffff000);

        assert_type_val(u15 >> 4, unsigned _BitInt(15), 0x7ff);
        assert_type_val(u16 >> 4, unsigned _BitInt(16), 0xfff);
        assert_type_val(u17 >> 4, unsigned _BitInt(17), 0x1fff);
        assert_type_val(u31 >> 4, unsigned _BitInt(31), 0x7ffffff);
        assert_type_val(u32 >> 4, unsigned _BitInt(32), 0xfffffff);
        assert_type_val(u33 >> 4, unsigned _BitInt(33), 0x1fffffff);
        assert_type_val(u47 >> 4, unsigned _BitInt(47), 0x7ffffffffff);
        assert_type_val(u48 >> 4, unsigned _BitInt(48), 0xfffffffffff);
        assert_type_val(u63 >> 4, unsigned _BitInt(63), 0x7ffffffffffffff);
        assert_type_val(u64 >> 4, unsigned _BitInt(64), 0xfffffffffffffff);

        assert_type_val((unsigned _BitInt(12))0x12345678, unsigned _BitInt(12), 0x678);
        assert_type_val((unsigned _BitInt(20))0x12345678, unsigned _BitInt(20), 0x45678);

        assert_type_val(0x0uwb, unsigned _BitInt(1), 0x0);
        assert_type_val(0x1uwb, unsigned _BitInt(1), 0x1);
        assert_type_val(0x7fffuwb, unsigned _BitInt(15), 0x7fff);
        assert_type_val(0xffffuwb, unsigned _BitInt(16), 0xffff);
        assert_type_val(0x1ffffuwb, unsigned _BitInt(17), 0x1ffff);
        assert_type_val(0x7fffffffuwb, unsigned _BitInt(31), 0x7fffffff);
        assert_type_val(0xffffffffuwb, unsigned _BitInt(32), 0xffffffff);
        assert_type_val(0x1ffffffffuwb, unsigned _BitInt(33), 0x1ffffffff);
        assert_type_val(0x7fffffffffffuwb, unsigned _BitInt(47), 0x7fffffffffff);
        assert_type_val(0xffffffffffffuwb, unsigned _BitInt(48), 0xffffffffffff);
        assert_type_val(0x7fffffffffffffffuwb, unsigned _BitInt(63), 0x7fffffffffffffff);
        assert_type_val(0xffffffffffffffffuwb, unsigned _BitInt(64), 0xffffffffffffffff);

        assert_type_val(0x0wb, _BitInt(2), 0x0);
        assert_type_val(0x1wb, _BitInt(2), 0x1);
        assert_type_val(0x7fffwb, _BitInt(16), 0x7fff);
        assert_type_val(0xffffwb, _BitInt(17), 0xffff);
        assert_type_val(0x1ffffwb, _BitInt(18), 0x1ffff);
        assert_type_val(0x7fffffffwb, _BitInt(32), 0x7fffffff);
        assert_type_val(0xffffffffwb, _BitInt(33), 0xffffffff);
        assert_type_val(0x1ffffffffwb, _BitInt(34), 0x1ffffffff);
        assert_type_val(0x7fffffffffffwb, _BitInt(48), 0x7fffffffffff);
        assert_type_val(0xffffffffffffwb, _BitInt(49), 0xffffffffffff);
        assert_type_val(0x7fffffffffffffffwb, _BitInt(64), 0x7fffffffffffffff);

        assert_type_val(0x0uwb + 0x0uwb, unsigned _BitInt(1), 0x0);
        assert_type_val(0x1uwb + 0x1uwb, unsigned _BitInt(1), 0x0);
        assert_type_val(0x7fffuwb + 0x7fffuwb, unsigned _BitInt(15), 0x7ffe);
        assert_type_val(0xffffuwb + 0xffffuwb, unsigned _BitInt(16), 0xfffe);
        assert_type_val(0x1ffffuwb + 0x1ffffuwb, unsigned _BitInt(17), 0x1fffe);
        assert_type_val(0x7fffffffuwb + 0x7fffffffuwb, unsigned _BitInt(31), 0x7ffffffe);
        assert_type_val(0xffffffffuwb + 0xffffffffuwb, unsigned _BitInt(32), 0xfffffffe);
        assert_type_val(0x1ffffffffuwb + 0x1ffffffffuwb, unsigned _BitInt(33), 0x1fffffffe);
        assert_type_val(0x7fffffffffffuwb + 0x7fffffffffffuwb, unsigned _BitInt(47), 0x7ffffffffffe);
        assert_type_val(0xffffffffffffuwb + 0xffffffffffffuwb, unsigned _BitInt(48), 0xfffffffffffe);
        assert_type_val(0x7fffffffffffffffuwb + 0x7fffffffffffffffuwb, unsigned _BitInt(63), 0x7ffffffffffffffe);
        assert_type_val(0xffffffffffffffffuwb + 0xffffffffffffffffuwb, unsigned _BitInt(64), 0xfffffffffffffffe);

        assert_type_val(0x0wb - 1wb, _BitInt(2), -1);
        assert_type_val(0x1wb - 1wb, _BitInt(2), 0);
        assert_type_val(0x7fffwb - 1wb, _BitInt(16), 0x7ffe);
        assert_type_val(0xffffwb - 1wb, _BitInt(17), 0xfffe);
        assert_type_val(0x1ffffwb - 1wb, _BitInt(18), 0x1fffe);
        assert_type_val(0x7fffffffwb - 1wb, _BitInt(32), 0x7ffffffe);
        assert_type_val(0xffffffffwb - 1wb, _BitInt(33), 0xfffffffe);
        assert_type_val(0x1ffffffffwb - 1wb, _BitInt(34), 0x1fffffffe);
        assert_type_val(0x7fffffffffffwb - 1wb, _BitInt(48), 0x7ffffffffffe);
        assert_type_val(0xffffffffffffwb - 1wb, _BitInt(49), 0xfffffffffffe);
        assert_type_val(0x7fffffffffffffffwb - 1wb, _BitInt(64), 0x7ffffffffffffffe);

        assert_type_val(1 ? (_BitInt(4))-1 : (unsigned _BitInt(4))1, unsigned _BitInt(4), 0xf);

        assert_compound_type(_BitInt(7), _BitInt(7), _BitInt(7));
        assert_compound_type(_BitInt(6), _BitInt(42), _BitInt(42));
        assert_compound_type(_BitInt(20), _BitInt(16), _BitInt(20));
        assert_compound_type(unsigned _BitInt(7), unsigned _BitInt(7), unsigned _BitInt(7));
        assert_compound_type(unsigned _BitInt(6), unsigned _BitInt(42), unsigned _BitInt(42));
        assert_compound_type(unsigned _BitInt(20), unsigned _BitInt(16), unsigned _BitInt(20));
        assert_compound_type(unsigned _BitInt(7), _BitInt(7), unsigned _BitInt(7));
        assert_compound_type(unsigned _BitInt(6), _BitInt(42), _BitInt(42));
        assert_compound_type(unsigned _BitInt(20), _BitInt(16), unsigned _BitInt(20));

        assert_compound_type(char, unsigned _BitInt(4), int);
        assert_compound_type(_BitInt(7), int, int);
        assert_compound_type(int, unsigned _BitInt(9), int);
        assert_compound_type(int, _BitInt(16), int);
#if INT_WIDTH == 16
        assert_compound_type(unsigned short, unsigned _BitInt(16), unsigned int);
        assert_compound_type(unsigned _BitInt(16), int, unsigned int);
#endif
        assert_compound_type(_BitInt(23), long, long);
        assert_compound_type(long, unsigned _BitInt(27), long);
#if LONG_WIDTH == 32
        assert_compound_type(unsigned _BitInt(32), long, unsigned long);
        assert_compound_type(long, _BitInt(40), _BitInt(40));
        assert_compound_type(unsigned _BitInt(64), long, unsigned _BitInt(64));
#endif
        assert_compound_type(_BitInt(50), long long, long long);
#if LLONG_WIDTH == 64
        assert_compound_type(long long, unsigned _BitInt(64), unsigned long long);
#endif

        static unsigned _BitInt(4) switchCond = 0xabcd;
        switch (switchCond) {
        case 0x1f: goto Fail;
        case 0x1d: break;
        default:   goto Fail;
        }

        printf ("Passed Conformance Test c23bitint\n");
        return 0;

Fail:
        printf ("Failed Conformance Test c23bitint\n");
}
