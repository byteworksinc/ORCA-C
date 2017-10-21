/* Deviance Test 4.6.5.1:  Ensure illegal enumeration initializations are */
/*                         detected                                       */

static struct S { int i; float f; } s = { 2, 4.5 };
static char ch [] = "hey!";

static enum E1 { a, b, c } e1 = s;
enum E2 { d, e, f } e2 = &ch;

main ()
  {
   enum E3 { g, h } e3 = &s;
   register enum E4 { i, j, k } e4 = ch;

   printf ("Failed Deviance Test 4.6.5.1\n");
  }
