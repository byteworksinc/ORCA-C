/* Conformance Test 2.1.0.3:  Verification of ANSI C trigraphs in */
/*                            character constants                 */

int printf(const char *, ...);

int main (void)
  {
   char a;

   a = '??=';                          /* ??= is '#' */
   if (a != '#')
       goto Fail;

   a = '??/??/';                       /* ??/ is '\' */
   if (a != 0x5C)
       goto Fail;

   a = '??'';                          /* ??' is '^' */
   if (a != '^')
       goto Fail;

   a = '??!';                          /* ??! is '|' */
   if (a != '|')
       goto Fail;

   a = '??-';                          /* ??- is '~' */
   if (a != '~')
       goto Fail;

   a = '??(';                          /* ??( is '[' */
   if (a != '[')
       goto Fail;

   a = '??<';                          /* ??< is '{' */
   if (a != '{')
       goto Fail;

   a = '??)';                          /* ??) is ']' */
   if (a != ']')
       goto Fail;

   a = '??>';                          /* ??> is '}' */
   if (a != '}')
       goto Fail;

   printf ("Passed Conformance Test 2.1.0.3\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 2.1.0.3\n");
  }
