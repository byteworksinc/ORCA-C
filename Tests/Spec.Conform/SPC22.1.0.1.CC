/* Special Conformance Test 22.1.0.1:  Verification of argv, argc    */
/*                                                                   */
/* Other files needed:  spc22.101.exec - EXEC file which compiles,   */
/*                                       links, and executes test    */
/*                                       file with 3 parameters      */

int main (int argc, char *argv [])
  {
   int count = 0;

   count++;
   if (argc != 4)
       goto Fail;

   count++;
   if (strcmp (argv [0], "3/spc22.1"))
       goto Fail;

   count++;
   if (strcmp (argv [1], "cat"))
       goto Fail;

   count++;
   if (strcmp (argv [2], "dog"))
       goto Fail;

   count++;
   if (strcmp (argv [3], "run"))
       goto Fail;

   printf ("Passed Special Conformance Test 22.1.0.1\n");
   return 0;

Fail:
   printf ("count = %d\n", count);
   printf ("Failed Special Conformance Test 22.1.0.1\n");
  }
