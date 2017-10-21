/* Conformance Test 2.5.0.4:  Test characters comprising identifiers for */
/*                            structures                                 */
main ()
  {
   struct _____________________________________________9 {

       int  ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\
_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz_____________01234567899876543210\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210;

       long ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\
_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz_____________01234567899876543210\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
0123456789987654321; } abcDEF, ABCdef;

   struct _____________________________________________9 s;

       abcDEF.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210 = 26;

       abcDEF.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321 = 2147483647; 

       ABCdef.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210 = 25;

       ABCdef.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321 = 2147483646; 

       s.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210 = -5;

       s.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321 = -2147483647; 

       if (abcDEF.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210 == \
       ABCdef.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210)
           goto Fail;

       if (abcDEF.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210 == \
       s.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210)
           goto Fail;

       if (abcDEF.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321 == \
       ABCdef.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321)
           goto Fail;

       if (abcDEF.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321 == \
       s.\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321)
           goto Fail;


   printf ("Passed Conformance Test 2.5.0.4\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.5.0.4\n");
 }
