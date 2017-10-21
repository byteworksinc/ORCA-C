/* Conformance Test 4.6.1.2:  Initialization of integer variables, using  */
/*                            curly-braced expressions.  Verification of  */
/*                            zeroing of non-initialized static variables */
/*                            is also checked.                            */

#define ONE 1
#define TWO 2

/* static and extern variables can only be initialized with constant exprs */

static int i;

long j = { ONE <= 5 };     /* default storage class at top-level is extern */
char ch = {~'a' - 0x20};

main ()
  {
   /* auto & register integers can be initialized with arbitrary expressions */
   /* default storage class at head of block is auto                         */

   static char chr8;
   static long longStatic;

   int k = { ch - j };
{  unsigned u1 = {k | i & j};
{  long m =      {(long) (u1 ^ k)};
   unsigned long n = {  4294967295ul >> k   };
   char chr =        { 'z' * (k / 'b') };

   register int k1 = {ch - j};
   register unsigned un1 = {k | i & j};
{  register long m1 = { (long) (u1 ^ k) };
   register unsigned long n1 = { 4294967295ul >> 8 };
   register char chr1 = { 'z' * (k / 'b') + TWO  };

   if ((i != 0) || (j != 1) || (ch != 0x7E) || (k != 0x7D) || (n1 != 0x00FFFFFF))
       goto Fail;

   if ((m != 0) || (n != 0) || (chr != 0x7A) || (k1 != 0x7D) || (un1 != 0x7D))
       goto Fail;

   if ((m1 != 0) || (n1 != 0x00FFFFFF) || (chr1 != 0x7C) || (chr8 != 0) || \
       (longStatic != 0))
       goto Fail;

   printf ("Passed Conformance Test 4.6.1.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.6.1.2\n");
}}}
  }
