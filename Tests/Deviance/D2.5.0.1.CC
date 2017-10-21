/* Deviance Test 2.5.0.1:  Ensure error flagging for invalid identifiers */
main ()
  {
   int       1n;
   char      !v_9;
   char      @wrk;
   char      #et;
   long      $hex;
   long      %percent;
   long      ^caret;
   long      &ampersand;
   short     *asterisk8876_L6, mid(_00;
   short     middle)paren;
   float     -minus;
   float     +plus;
   float     eq=ual;
   double    {curly;
   extended  brack}et;

   extern int   square[;
   extern comp  qu"ote;

   static unsigned char  ]bracket;
   static unsigned short t'ic;

   extern long  less<than;
   static char  greater>than;
   float        quest?ion;
   double       period.;
   extern float  ti~lde;
   int           gra`ve;
   long          bar|;
   unsigned char back\slash;
   char          sla/sh;

   printf ("Failed Deviance Test 2.5.0.1\n");
 }
