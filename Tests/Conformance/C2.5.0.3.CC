/* Conformance Test 2.5.0.3:  Test characters comprising identifiers for */
/*                            user-defined types                         */
main ()
  {
   typedef short  _____________________________________________9;

   typedef long   \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210;

   typedef float  \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321;

ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210 x;

ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321  y; 

   _____________________________________________9 s;

   s = 0x7FFF;
   if (s != 32767)
       goto Fail;

   x = 0x7FFFFFFF;
   if (x != 2147483647)
       goto Fail;

   y = 97.5;
   if (y != .975e+2)
       goto Fail;

   printf ("Passed Conformance Test 2.5.0.3\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.5.0.3\n");
 }
