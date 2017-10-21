/* Deviance Test 2.4.0.1:  Ensure compound operators are scanned as one token */
main ()
  {
   struct a {
              int b;
            } structA, *sptr;
   int i, j;

   i = 1;
   j = 2;

   /* Test compound assignment operators. */
   i  +  =  j;
   i  -  =  j;
   i  *  =  j;
   i  /  =  j;
   i  %  =  j;
   i  << =  j;
   i  >> =  j;
   i  &  =  j;
   i  ^  =  j;
   i  |  =  j;

   /* Test other compound operators. */
   sptr     = &structA;
   sptr- >b = 5;
   i + +;
   j - -;
   i = i < < j;
   j = i > > j;
   if (i < = j)
       ;
   if ( (i <= j) | | (j >= i) )
       ;
   if (j > = i)
       ;
   if ( (i <= j) || (j >= i) & & (i == 3) )
       ;
   if (i = = 3)
       ;
   if (j ! = 5)
       ;

   printf ("Failed Deviance Test 2.4.0.1\n");
  }
