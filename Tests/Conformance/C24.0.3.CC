/* Conformance Test 24.0.3:  Test the use of the extended character set  */

#pragma lint -1

#include <stdio.h>
#include <string.h>

typedef enum {false, true} boolean;

void main (void)

{
boolean fail;
int a, b, c, i;
char str[128];

int €‘‚’ƒ“„”´Ä…•µ†–¶Æ‡—§·ˆ˜¸Ø‰™¹Šš‹›»ËŒœ¼Ì½Í®¾ÎŞŸ¯¿Ïß;
int €‘‚’ƒ“„”´Ä…•µ†„ÆÆ‡—§·Ë˜¸Ø‰™¹€…ÌÍ»Ëœ¼Ì‚½Íƒ®®ÎŞ†¯¯Îß;

/* Make sure alpha-"looking" characters are allowed in identifiers,
   and that the lowercase versions are distinct from the uppercase
   versions. */
fail = false;
   €‘‚’ƒ“„”´Ä…•µ†–¶Æ‡—§·ˆ˜¸Ø‰™¹Šš‹›»ËŒœ¼Ì½Í®¾ÎŞŸ¯¿Ïß = 4;
   €‘‚’ƒ“„”´Ä…•µ†„ÆÆ‡—§·Ë˜¸Ø‰™¹€…ÌÍ»Ëœ¼Ì‚½Íƒ®®ÎŞ†¯¯Îß = 5;
if (€‘‚’ƒ“„”´Ä…•µ†–¶Æ‡—§·ˆ˜¸Ø‰™¹Šš‹›»ËŒœ¼Ì½Í®¾ÎŞŸ¯¿Ïß != 4)
   fail = true;

/* Make sure all special characters are allowed in strings */
strcpy(str, "");
for (i = 17; i <= 20; ++i)
   if (str[i - 17] != i) {
      fail = true;
      printf("Character %d was incorrect in str.\n", i);
      }
strcpy(str, "€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ ¡¢£¤¥¦§¨©ª«"
            "¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×Ø");
for (i = 128; i <= 216; ++i)
   if (str[i - 128] != i) {
      fail = true;
      printf("Character %d was incorrect in str.\n", i);
      }
if ('Ş' != 222) {
   fail = true;
   printf("Character 222 was incorrect in str.\n");
   }
if ('ß' != 223) {
   fail = true;
   printf("Character 223 was incorrect in str.\n");
   }

/* Make sure all special characters are allowed in comments */
/* The special character set is:

   0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

0           0  @  P  `  p  €       °  À  Ğ
1       !  1  A  Q  a  q    ‘  ¡  ±  Á  Ñ
2       "  2  B  R  b  r  ‚  ’  ¢  ²  Â  Ò
3       #  3  C  S  c  s  ƒ  “  £  ³  Ã  Ó
4       $  4  D  T  d  t  „  ”  ¤  ´  Ä  Ô
5        %  5  E  U  e  u  …  •  ¥  µ  Å  Õ
6        &  6  F  V  f  v  †  –  ¦  ¶  Æ  Ö
7        '  7  G  W  g  w  ‡  —  §  ·  Ç  ×
8        (  8  H  X  h  x  ˆ  ˜  ¨  ¸  È  Ø
9        )  9  I  Y  i  y  ‰  ™  ©  ¹  É
A        *  0  J  Z  j  z  Š  š  ª  º  Ê
B        +  :  K  [  k  {  ‹  ›  «  »  Ë
C        ,  ;  L  \  l  |  Œ  œ  ¬  ¼  Ì
D        _  <  M  ]  m  }      ­  ½  Í
E        .  =  N  ^  n  ~      ®  ¾  Î  Ş
F        /  ?  O  _  o       Ÿ  ¯  ¿  Ï  ß
*/

/* Make sure the special operators work */
/* Some lines also test the non-breaking space */
aÊ=Ê100;
bÊ=Ê3;
cÊ=ÊaÖb;
ifÊ(aÊ²Êb)
   fail = true;
if (! (a ² a))
   fail = true;
if (b ³ a)
   fail = true;
if (! (b ³ b))
   fail = true;
if (c ­ 33)
   fail = true;
c = a Ç 2;
if (c ­ 400)
   fail = true;
c = a È 2;
if (c ­ 25)
   fail = true;

if (!fail)
   printf("Passed Conformance Test 24.0.3\n");
else
   printf("Failed Conformance Test 24.0.3\n");
}
