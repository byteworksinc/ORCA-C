/* Conformance Test 2.2.0.2:  Comments crossing multiple lines */

int printf(const char *, ...);

int main (void)
  {
   /* Should ignore this
       comment line
       as well as this comment line
       and this
       and this
       and this
       and this
       and this
                                           */
       printf ("Passed Conformance Test 2.2.0.2\n");
                                                   }
