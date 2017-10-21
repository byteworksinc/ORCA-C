/* Special Conformance Test 4.6.3.5: Verification of pointer initialization:  */
/*                                   setting pointer to integer constant      */
/*                                                                            */
/* Tester needs to enter one character from the keyboard and then check that  */
/* the key echoed is the same key.                                            */
/*                                                                            */

main ()
  {
   static char *keyBoard = (char *) 0xC000ul, *strobe = (char *) 0xC010ul, ch;

   *keyBoard = 0;
   printf ("Please type one character\n");
   while (!(*keyBoard & 0x0080)) ;
   *strobe = 1;
   ch = *keyBoard;
   printf ("The character typed is: %c\n", ch);
   return;

Fail:
   printf ("Failed Special Conformance Test 4.6.3.5\n");
  }
