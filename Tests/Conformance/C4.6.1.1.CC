/* Conformance Test 4.6.1.1:  Initialization of integer variables */

#define ONE 1
#define TWO 2

/* static and extern variables can only be initialized with constant exprs */

static int i = 8 << 2 + 6 - 7 / 3 >> 1 * 5 % (sizeof (int));

long j = ONE <= 5;         /* default storage class at top-level is extern */
char ch = ~'a' - 0x20;
int gk = 0x7D;
unsigned gu1 = 0x7D;

main ()
  {
   /* auto & register integers can be initialized with arbitrary expressions */
   /* default storage class at head of block is auto                         */

   int k = ch - j;
   unsigned u1 = gk | i & j;
   long m = (long) (gu1 ^ gk);
   unsigned long n = 4294967295ul >> gk;
   char chr = 'z' * (gk / 'b');

   register int k1 = ch - j;
   register unsigned un1 = gk| i & j;
   register long m1 = (long) (gu1 ^ gk);
   register unsigned long n1 = 4294967295ul >> 8;
   register char chr1 = 'z' * (gk / 'b') + TWO;

   if ((i != 0x100) || (j != 1) || (ch != 0x7E) || (k != 0x7D) ||
       (n1 != 0x00FFFFFF))
       goto Fail;

   if ((m != 0) || (n != 0) || (chr != 0x7A) || (k1 != 0x7D) || (un1 != 0x7D))
       goto Fail;

   if ((m1 != 0) || (chr1 != 0x7C))
       goto Fail;

   printf ("Passed Conformance Test 4.6.1.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.6.1.1\n");
  }
