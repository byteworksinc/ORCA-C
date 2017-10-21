/* Deviance Test 3.3.1.1:  Ensure invalid simple macro definitions are */
/*                         flagged as errors                           */

#DEfine  BadDef        10
#DEFINE  anotherBaddef 20
#define  7*8           name goes first!
#define                /* oops -- no name A-tall!!! */

main ()
  {
   printf ("Failed Deviance Test 3.3.1.1\n");
  }
