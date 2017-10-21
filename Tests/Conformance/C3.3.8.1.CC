/* Conformance Test 3.3.8.1:  Verification of converting tokens to strings */
/*                            within macros                                */

#define    CnvToString1(a,b,c) "not a " #a " nor a c" #c " nor a m" #b\
" be me\n"
#define    CnvToString2(a,b,c) "a = " #a " b = " #b " c = "#c

main ()
  {
   char string1[] = CnvToString1 (5, 276.145, 0x7F);
   char string2[] = CnvToString2 (4, 3, 0);

   if ((strcmp (string1, "not a 5 nor a c0x7F nor a m276.145 be me\n")) != 0)
       goto Fail;
   if ((strcmp (string2, "a = 4 b = 3 c = 0")) != 0)
       goto Fail;

   printf ("Passed Conformance Test 3.3.8.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 3.3.8.1\n");
  }
