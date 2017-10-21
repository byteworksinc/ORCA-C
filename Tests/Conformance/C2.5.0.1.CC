/* Conformance Test 2.5.0.1:  Test characters comprising identifiers for */
/*                            variables                                  */
main ()
  {
   int    a_______________000000000000000000000000000000;
   short  _____________________________________________9;

   long   \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210;

   long   \
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321;

   char   abc;
   char   aBc;

ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210 = 8;

ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321 = 3; 

   if (\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________01234567899876543210 != 8)
       goto Fail;

   if (\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_____________\
01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs\
tuvwxyz_____________01234567899876543210ABCDEFGHIJKLMNOPQRSTUVWXY\
Zabcdefghijklmnopqrstuvwxyz_____________0123456789987654321 != 3)
        goto Fail;

   abc = 'a';
   aBc = 'b';
   if ((abc == 'b') || (aBc == 'a'))
       goto Fail;

   a_______________000000000000000000000000000000 = 32767;
   if (a_______________000000000000000000000000000000 != 0x7FFF)
       goto Fail;

   _____________________________________________9 = -4009;
   if (_____________________________________________9 != -4009)
       goto Fail;

   printf ("Passed Conformance Test 2.5.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.5.0.1\n");
 }
