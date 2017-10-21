/* Deviance Test 3.3.4.1:  Ensure cannot redefine or undefine ORCA/C's */
/*                         predefined macros                           */

#define    __LINE__    5
#define    __FILE__    "d3.3.4.1.cc"
#define    __DATE__    "Mar 01 1989"
#define    __TIME__    "10:10:10"
#define    __STDC__    illegal redefinition of __STDC__

#undef    __LINE__
#undef    __FILE__
#undef    __DATE__
#undef    __TIME__
#undef    __STDC__

main ()
  {
   printf ("Failed Deviance Test 3.3.4.1\n");
  }
