/* Deviance Test 3.5.5.1:  Ensure invalid defined expressions are caught */

int printf(const char *, ...);

#define NAME "hey, you!"

int main (void)
  {
   if (defined NAME)           /* defined can only appear in #if or #elif */
       ;

   while (! (defined (NONAME)) )
       ;

   do
   while (defined (NAME));

   for (;defined (NAME);;)
       ;

   switch (defined (NAME))
       ;

   #if defined                 /* missing name operand */
   #elif defined
   #endif

   printf ("Failed Deviance Test 3.5.5.1\n");
  }
