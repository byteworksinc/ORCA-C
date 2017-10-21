/* Deviance Test 4.6.1.1:  Ensure non-constant initialization of static and */
/*                         extern variables is detected                     */

static int  i = 5;
static int  j = i + 2;
static long L1 = &i - j;
static char ch1 = (char) L1 / i;
static unsigned int  u1 = 5 >> ch1;
static unsigned long ul1 = (unsigned long) (u1);

int  ext1 = r7 * 7;
long ext2 = (int) 98.7 - i;
char ext3 = ch1 / ch1;
unsigned int  ext4 = ext3 || ext1;
unsigned long ext5 = ul1;

main ()
  {
   static int  m1 = m1 - 0;
   static long m2 = ch1;
   static char m3 = 'a' + 'b' - ext3;
   static unsigned int  m4 = m2 + ul1;
   static unsigned long m5 = ext5;

   printf ("Failed Deviance Test 4.6.1.1\n");
  }
