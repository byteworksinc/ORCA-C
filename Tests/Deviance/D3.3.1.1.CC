/* Deviance Test 3.3.1.1:  Ensure invalid simple macro definitions are */
/*                         flagged as errors                           */

int printf(const char *, ...);

#DEfine  BadDef        10
#DEFINE  anotherBaddef 20
#define  7*8           name goes first!
#define                /* oops -- no name A-tall!!! */

int main (void)
  {
   printf ("Failed Deviance Test 3.3.1.1\n");
  }
