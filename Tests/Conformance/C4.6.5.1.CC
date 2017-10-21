/* Conformance Test 4.6.5.1:  Verification of enumeration initializations */

static enum E1 { a, b, c } e1 = b;
enum E2 { d, e } e2 = e;

main ()
  {
   enum E3 { f, g, h } e3 = f;
{  enum E3 e4 = e3;

   register enum E4 { i, j, k } e8 = j;
   enum E4 e5 = e8;
   enum E2 e6 = d;
   enum E1 e7 = e1;

   if ((e1 != b) || (e2 != e) || (e3 != f) || (e4 != f) || (e5 != j) ||
       (e6 != d) || (e7 != b))
       goto Fail;

   printf ("Passed Conformance Test 4.6.5.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 4.6.5.1\n");
   }
  }
