/* Conformance Test 3.3.1.1:  Verification of simple macro definitions */

#define A_LONG_MACRO_NAME   7 * 3999 / 18 + count - digits;
#define SUBSTITUTION        a_variable
#define EXPRESSION          (3 + 21 / 6)
#define STRING"This string was made for testing, and that's just what\
               it does"
#define LABEL     Fail
#define begin     {
#define end       }
#define pass_msg  ("Passed Conformance Test 3.3.1.1\n");
#define letsSplit return

main ()
  begin
   long SUBSTITUTION;
   char string [] = STRING;
   int  i, count, digits;

   if ((strcmp (string,"This string was made for testing, and that's \
just what               it does")) != 0)
       goto Fail;

   a_variable = (long) (EXPRESSION);
   if (a_variable != 6)
       goto LABEL;

   count  = 5;
   digits = 20;
   i      = A_LONG_MACRO_NAME
   if (i != 1540)
       goto LABEL;

   printf pass_msg
   letsSplit;

Fail:
   printf ("Failed Conformance Test 3.3.1.1\n");
  end
