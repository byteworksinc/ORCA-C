/* Conformance Test 3.3.2.4:  Postfix increment and decrement operators */

#pragma debug 32

#include <stdio.h>

char buf[8] = "abcdefg";
char *ptrs[2];

int main (void)
  {
   char *p, *q;
   char **pp;
   char c;
   long n;

   p = buf;
   n = 0;
   c = *p++;
   if ((c != 'a') || (p != buf + 1))
       goto Fail;

   n = 0;
   *p++ = 'B';
   if ((buf[1] != 'B') || (p != buf + 2))
       goto Fail;

   n = 0;
   c = *p--;
   if ((c != 'c') || (p != buf + 1))
       goto Fail;

   n = 5;
   q = p++;
   if ((q != buf + 1) || (p != buf + 2) || (n != 5))
       goto Fail;

   pp = ptrs;
   n = 0;
   *pp++ = buf;
   if ((ptrs[0] != buf) || (pp != ptrs + 1))
       goto Fail;

   printf ("Passed Conformance Test 3.3.2.4\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 3.3.2.4\n");
   return 1;
  }