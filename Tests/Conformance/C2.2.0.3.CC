/* Conformance test 2.2.0.3:  Comments in preprocessor lines */

int printf(const char *, ...);

#define ten /* ten:
                          one greater
                          than nine
               */  (2 * 5)
int main (void)
  {
   if (ten == 10)
     {
       printf ("Passed Conformance Test 2.2.0.3\n");
     }
   else
     {
       printf ("Failed Conformance Test 2.2.0.3\n");
     }
   }
