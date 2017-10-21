/* Conformance Test 2.7.4.1:  Test implementation of ORCA/C p-strings */
main ()
  {
   char a [300];

   strcpy (a, "\pabc");        /* "abc" should be a p-string */
   if (a[0] != 3)
       goto Fail;

   strcpy (a, "\pThis is a longer string than the last one...");
   if (a[0] != 44)
       goto Fail;

   strcpy (a, "not a \p-string");
   if ((strcmp (a, "not a p-string")) != 0)
       goto Fail;

   printf ("Passed Conformance Test 2.7.4.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.4.1\n");
  }
