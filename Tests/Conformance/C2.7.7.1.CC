/* Conformance Test 2.7.7.1:  Verification of numeric escape codes in */
/*                            character constants                     */
main ()
  {
   char a;

   a = '\000';
   if (a != '\x0')
       goto Fail;

   a = '\001';
   if (a != '\x1')
       goto Fail;

   a = '\002';
   if (a != '\x2')
       goto Fail;

   a = '\007';                              /* alert character = bell   */
   if ((a != '\x7') || (a != '\a'))
       goto Fail;

   a = '\010';                              /* back space               */
   if ((a != '\x8') || (a != '\b'))
       goto Fail;

   a = '\011';                              /* horizontal tab           */
   if ((a != '\x9') || (a != '\t'))
       goto Fail;

   a = '\012';                              /* line feed = newline      */
   if ((a != '\xA') || (a != '\n'))
       goto Fail;

   a = '\013';                              /* vertical tab             */
   if ((a != '\xB') || (a != '\v'))
       goto Fail;

   a = '\014';                              /* form feed                */
   if ((a != '\xC') || (a != '\f'))
       goto Fail;

   a = '\015';                              /* carriage return          */
   if ((a != '\xD') || (a != '\r'))
       goto Fail;

   a = '\016';
   if (a != '\xE')
       goto Fail;

   a = '\017';
   if (a != '\xF')
       goto Fail;

   a = '\020';
   if (a != '\x10')
       goto Fail;

   a = '\021';
   if (a != '\x11')
       goto Fail;

   a = '\036';
   if (a != '\x1E')
       goto Fail;

   a = '\037';
   if (a != '\x1F')
       goto Fail;

   a = '\040';                              /* blank                    */
   if ((a != '\x20') || (a != ' '))
       goto Fail;

   a = '\041';                              /* exclamation point        */
   if ((a != '\x21') || (a != '!'))
       goto Fail;

   a = '\042';                              /* double quote mark        */
   if ((a != '\x22') || (a != '"'))
       goto Fail;

   a = '\043';                              /* pound sign               */
   if ((a != '\x23') || (a != '#'))
       goto Fail;

   a = '\044';                              /* dollar sign              */
   if ((a != '\x24') || (a != '$'))
       goto Fail;

   a = '\045';                              /* percent sign             */
   if ((a != '\x25') || (a != '%'))
       goto Fail;

   a = '\046';                              /* ampersand                */
   if ((a != '\x26') || (a != '&'))
       goto Fail;

   a = '\047';                              /* apostrophe               */
   if ((a != '\x27') || (a != '\''))
       goto Fail;

   a = '\062';                              /* character two            */
   if ((a != '\x32') || (a != '2'))
       goto Fail;

   a = '\063';                              /* character three          */
   if ((a != '\x33') || (a != '3'))
       goto Fail;

   a = '\064';                              /* character four           */
   if ((a != '\x34') || (a != '4'))
       goto Fail;

   a = '\065';                              /* character five           */
   if ((a != '\x35') || (a != '5'))
       goto Fail;

   a = '\066';                              /* character six            */
   if ((a != '\x36') || (a != '6'))
       goto Fail;

   a = '\077';                             /* question mark            */
   if ((a != '\x3F') || (a != '?'))
       goto Fail;

   a = '\100';                             /* at sign                  */
   if ((a != '\x40') || (a != '@'))
       goto Fail;

   a = '\101';
   if ((a != '\x41') || (a != 'A'))
       goto Fail;

   a = '\120';
   if ((a != '\x50') || (a != 'P'))
       goto Fail;

   a = '\121';
   if ((a != '\x51') || (a != 'Q'))
       goto Fail;

   a = '\122';
   if ((a != '\x52') || (a != 'R'))
       goto Fail;

   a = '\123';
   if ((a != '\x53') || (a != 'S'))
       goto Fail;

   a = '\124';
   if ((a != '\x54') || (a != 'T'))
       goto Fail;

   a = '\125';
   if ((a != '\x55') || (a != 'U'))
       goto Fail;

   a = '\126';
   if ((a != '\x56') || (a != 'V'))
       goto Fail;

   a = '\127';
   if ((a != '\x57') || (a != 'W'))
       goto Fail;

   a = '\130';
   if ((a != '\x58') || (a != 'X'))
       goto Fail;

   a = '\131';
   if ((a != '\x59') || (a != 'Y'))
       goto Fail;

   a = '\132';
   if ((a != '\x5A') || (a != 'Z'))
       goto Fail;

   a = '\133';                             /* left square bracket      */
   if ((a != '\x5B') || (a != '['))
       goto Fail;

   a = '\134';                             /* back slash               */
   if ((a != '\x5C') || (a != '\\'))
       goto Fail;

   a = '\135';                             /* right square bracket     */
   if ((a != '\x5D') || (a != ']'))
       goto Fail;

   a = '\136';                             /* caret mark               */
   if ((a != '\x5E') || (a != '^'))
       goto Fail;

   a = '\137';                             /* underscore               */
   if ((a != '\x5F') || (a != '_'))
       goto Fail;

   a = '\140';                             /* accent grave             */
   if ((a != '\x60') || (a != '`'))
       goto Fail;

   a = '\141';
   if ((a != '\x61') || (a != 'a'))
       goto Fail;

   a = '\142';
   if ((a != '\x62') || (a != 'b'))
       goto Fail;

   a = '\143';
   if ((a != '\x63') || (a != 'c'))
       goto Fail;

   a = '\144';
   if ((a != '\x64') || (a != 'd'))
       goto Fail;

   a = '\172';
   if ((a != '\x7A') || (a != 'z'))
       goto Fail;

   a = '\173';                             /* left curly bracket   */
   if ((a != '\x7B') || (a != '{'))
       goto Fail;

   a = '\174';                             /* vertical bar         */
   if ((a != '\x7C') || (a != '|'))
       goto Fail;

   a = '\175';                             /* right curly bracket  */
   if ((a != '\x7D') || (a != '}'))
       goto Fail;

   a = '\176';                             /* tilde                */
   if ((a != '\x7E') || (a != '~'))
       goto Fail;

   a = '\177';                             /* rubout               */
   if (a != '\x7F')
       goto Fail;

   printf ("Passed Conformance Test 2.7.7.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.7.1\n");
  }
