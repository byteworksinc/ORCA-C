/* Conformance Test 2.5.0.6:  Test characters comprising identifiers for */
/*                            enumerations                               */
main ()
  {
   enum _____________________________________________9 {

       ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\
_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz_____________01234567899876543210\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210,

       ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\
_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz_____________01234567899876543210\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
0123456789987654321 } abcDEF, ABCdef;

   enum _____________________________________________9 s;

   /* Assign and check 1st enum field for each variable. */
   abcDEF = \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210;

   ABCdef = \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210;

   s = \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210;

   if ((abcDEF != ABCdef) || (abcDEF != s) || (ABCdef != 0))
       goto Fail;

   /* Assign and check 2nd union field for each variable. */
   abcDEF = \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321; 

   ABCdef = \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321; 

   s = \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321; 

   if ((abcDEF != ABCdef) || (s != abcDEF) || (s != 1))
           goto Fail;

   printf ("Passed Conformance Test 2.5.0.6\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.5.0.6\n");
 }
