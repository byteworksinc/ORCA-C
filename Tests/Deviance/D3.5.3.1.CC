/* Deviance Test 3.5.3.1:  Ensure only macro names can be checked with the */
/*                         #ifdef and #ifndef commands                     */

int printf(const char *, ...);

int main (void)
  {
   #ifdef a * 2
   #endif

   #ifndef intPtr << 8
   #endif

   #ifdef 76.5 - 8
   #endif

   #ifndef
   #endif

   printf ("Failed Deviance Test 3.5.3.1\n");
  }
