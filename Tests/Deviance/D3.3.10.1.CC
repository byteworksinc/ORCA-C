/* Deviance Test 3.3.10.1:  Ensure macro bodies contain only complete tokens */

int printf(const char *, ...);

#define    BadExp1     $
#define    BadExp2     @~
#define    BadChar1    'a
#define    BadChar2    z'
#define    BadString1  "not a complete string
#define    BadString2  nor is this"

int main (void)
  {
   printf ("Failed Deviance Test 3.3.10.1\n");
  }
