/* Conformance Test 2.5.0.7:  Test characters comprising identifiers for */
/*                            preprocessor macros                        */
#define  _____________________________________________9  10

#define  ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\
_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz_____________01234567899876543210\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210  20

#define  ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\
_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz_____________01234567899876543210\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
0123456789987654321   30

main ()
  {
   if (_____________________________________________9 != 10)
       goto Fail;

   if (ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210 != 20)
       goto Fail;

   if (ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321 != 30)
       goto Fail; 

   printf ("Passed Conformance Test 2.5.0.7\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.5.0.7\n");
 }
