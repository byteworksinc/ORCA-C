/* Test 2.2.0.1:  in-line comments */

int printf(const char *, ...);

int main (/* This should be ignored */ void)
   /*{ brackets should not be seen }*/
   {
   printf ("Passed Conformance Test 2.2.0.1\n");
   /**//*****/}
