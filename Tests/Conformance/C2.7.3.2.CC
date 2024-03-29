/* Conformance Test 2.7.3.2:  Ensure char variables are implemented as */
/*                            unsigned 8-bit integers                  */

int printf(const char *, ...);

int main (void)
  {
   char a;
   int  i;

   for (i = 0; i < 256; i++)
     {
       a = i;
       if (a != i)
           goto Fail;
     }

   printf ("Passed Conformance Test 2.7.3.2\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 2.7.3.2\n");
  }
