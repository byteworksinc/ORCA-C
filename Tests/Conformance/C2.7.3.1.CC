/* Conformance Test 2.7.3.1:  Check ASCII encodings for all character */
/*                            constants                               */
main ()
  {
   char a;

   /* Check all printing characters. */
   a = ' ';
   if (a != 0x20)
       goto Fail;

   a = '!';
   if (a != 0x21)
       goto Fail;

   a = '"';
   if (a != 0x22)
       goto Fail;

   a = '#';
   if (a != 0x23)
       goto Fail;

   a = '$';
   if (a != 0x24)
       goto Fail;

   a = '%';
   if (a != 0x25)
       goto Fail;

   a = '&';
   if (a != 0x26)
       goto Fail;

   a = '(';
   if (a != 0x28)
       goto Fail;

   a = ')';
   if (a != 0x29)
       goto Fail;

   a = '*';
   if (a != 0x2A)
       goto Fail;

   a = '+';
   if (a != 0x2B)
       goto Fail;

   a = ',';
   if (a != 0x2C)
       goto Fail;

   a = '-';
   if (a != 0x2D)
       goto Fail;

   a = '.';
   if (a != 0x2E)
       goto Fail;

   a = '/';
   if (a != 0x2F)
       goto Fail;

   a = '0';
   if (a != 0x30)
       goto Fail;

   a = '1';
   if (a != 0x31)
       goto Fail;

   a = '2';
   if (a != 0x32)
       goto Fail;

   a = '3';
   if (a != 0x33)
       goto Fail;

   a = '4';
   if (a != 0x34)
       goto Fail;

   a = '5';
   if (a != 0x35)
       goto Fail;

   a = '6';
   if (a != 0x36)
       goto Fail;

   a = '7';
   if (a != 0x37)
       goto Fail;

   a = '8';
   if (a != 0x38)
       goto Fail;

   a = '9';
   if (a != 0x39)
       goto Fail;

   a = ':';
   if (a != 0x3A)
       goto Fail;

   a = ';';
   if (a != 0x3B)
       goto Fail;

   a = '<';
   if (a != 0x3C)
       goto Fail;

   a = '=';
   if (a != 0x3D)
       goto Fail;

   a = '>';
   if (a != 0x3E)
       goto Fail;

   a = '?';
   if (a != 0x3F)
       goto Fail;

   a = '@';
   if (a != 0x40)
       goto Fail;

   a = 'A';
   if (a != 0x41)
       goto Fail;

   a = 'B';
   if (a != 0x42)
       goto Fail;

   a = 'C';
   if (a != 0x43)
       goto Fail;

   a = 'D';
   if (a != 0x44)
       goto Fail;

   a = 'E';
   if (a != 0x45)
       goto Fail;

   a = 'F';
   if (a != 0x46)
       goto Fail;

   a = 'G';
   if (a != 0x47)
       goto Fail;

   a = 'H';
   if (a != 0x48)
       goto Fail;

   a = 'I';
   if (a != 0x49)
       goto Fail;

   a = 'J';
   if (a != 0x4A)
       goto Fail;

   a = 'K';
   if (a != 0x4B)
       goto Fail;

   a = 'L';
   if (a != 0x4C)
       goto Fail;

   a = 'M';
   if (a != 0x4D)
       goto Fail;

   a = 'N';
   if (a != 0x4E)
       goto Fail;

   a = 'O';
   if (a != 0x4F)
       goto Fail;

   a = 'P';
   if (a != 0x50)
       goto Fail;

   a = 'Q';
   if (a != 0x51)
       goto Fail;

   a = 'R';
   if (a != 0x52)
       goto Fail;

   a = 'S';
   if (a != 0x53)
       goto Fail;

   a = 'T';
   if (a != 0x54)
       goto Fail;

   a = 'U';
   if (a != 0x55)
       goto Fail;

   a = 'V';
   if (a != 0x56)
       goto Fail;

   a = 'W';
   if (a != 0x57)
       goto Fail;

   a = 'X';
   if (a != 0x58)
       goto Fail;

   a = 'Y';
   if (a != 0x59)
       goto Fail;

   a = 'Z';
   if (a != 0x5A)
       goto Fail;

   a = '[';
   if (a != 0x5B)
       goto Fail;

   a = ']';
   if (a != 0x5D)
       goto Fail;

   a = '^';
   if (a != 0x5E)
       goto Fail;

   a = '_';
   if (a != 0x5F)
       goto Fail;

   a = 'a';
   if (a != 0x61)
       goto Fail;

   a = 'b';
   if (a != 0x62)
       goto Fail;

   a = 'c';
   if (a != 0x63)
       goto Fail;

   a = 'd';
   if (a != 0x64)
       goto Fail;

   a = 'e';
   if (a != 0x65)
       goto Fail;

   a = 'f';
   if (a != 0x66)
       goto Fail;

   a = 'g';
   if (a != 0x67)
       goto Fail;

   a = 'h';
   if (a != 0x68)
       goto Fail;

   a = 'i';
   if (a != 0x69)
       goto Fail;

   a = 'j';
   if (a != 0x6A)
       goto Fail;

   a = 'k';
   if (a != 0x6B)
       goto Fail;

   a = 'l';
   if (a != 0x6C)
       goto Fail;

   a = 'm';
   if (a != 0x6D)
       goto Fail;

   a = 'n';
   if (a != 0x6E)
       goto Fail;

   a = 'o';
   if (a != 0x6F)
       goto Fail;

   a = 'p';
   if (a != 0x70)
       goto Fail;

   a = 'q';
   if (a != 0x71)
       goto Fail;

   a = 'r';
   if (a != 0x72)
       goto Fail;

   a = 's';
   if (a != 0x73)
       goto Fail;

   a = 't';
   if (a != 0x74)
       goto Fail;

   a = 'u';
   if (a != 0x75)
       goto Fail;

   a = 'v';
   if (a != 0x76)
       goto Fail;

   a = 'w';
   if (a != 0x77)
       goto Fail;

   a = 'x';
   if (a != 0x78)
       goto Fail;

   a = 'y';
   if (a != 0x79)
       goto Fail;

   a = 'z';
   if (a != 0x7A)
       goto Fail;

   a = '{';
   if (a != 0x7B)
       goto Fail;

   a = '|';
   if (a != 0x7C)
       goto Fail;

   a = '}';
   if (a != 0x7D)
       goto Fail;

   a = '~';
   if (a != 0x7E)
       goto Fail;

   /* Check all escape characters. */
   a = '\n';                       /* newline          */
   if (a != 0x0A)
       goto Fail;

   a = '\t';                       /* horizontal tab   */
   if (a != 0x09)
       goto Fail;

   a = '\b';                       /* back space       */
   if (a != 0x08)
       goto Fail;

   a = '\r';                       /* carriage return  */
   if (a != 0x0D)
       goto Fail;

   a = '\f';                       /* form feed        */
   if (a != 0x0C)
       goto Fail;

   a = '\v';                       /* vertical tab     */
   if (a != 0x0B)
       goto Fail;

   a = '\'';                       /* apostrophe       */
   if (a != 0x27)
       goto Fail;

   a = '\"';                       /* double quotes    */
   if (a != 0x22)
       goto Fail;

   a = '\\';                       /* back slash       */
   if (a != 0x5C)
       goto Fail;

   a = '\a';                       /* alert            */
   if (a != 0x07)
       goto Fail;

   a = '\?';                       /* question mark    */
   if (a != 0x3F)
       goto Fail;

   printf ("Passed Conformance Test 2.7.3.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.3.1\n");
  }
