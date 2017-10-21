/* Conformance Test 3.3.5.1:  Verification of undefining/redefining macros */

#undef     macroNotDefinedYet          /* not an error to undefine an */
                                       /*   undefined macro           */
#define    macroNotDefinedYet  8
#define    macroNotDefinedYet  8       /* allow only "benign" redefinition */
#undef     macroNotDefinedYet          /*   without intervening #undef     */
#define    macroNotDefinedYet  23      /* allow infinite undefining and    */
                                       /*   redefining                     */
#define    A23__BD8            "These are the days"
#undef     A23__BD8
#define    A23__BD8            27.3e5
#undef     A23__BD8
#define    A23__BD8            "Passed Conformance Test 3.3.5.1\n"

main ()
  {
   if (macroNotDefinedYet != 23)
       goto Fail;

   printf (A23__BD8);
   return;

Fail:
   printf ("Failed Conformance Test 3.3.5.1\n");
  }
