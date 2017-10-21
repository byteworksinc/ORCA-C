/* Conformance Test 2.7.7.2:  Verification of numeric escape codes */
/*                            within character strings             */
main ()
  {
   char a [300];

   strcpy (a, "\07a\010b\011c\012d\013e\014f\015g\016h\017i\020j");
   if ((strcmp (a, "\aa\bb\tc\nd\ve\ff\rg\xeh\xfi\x10j")) != 0)
       goto Fail;

   strcpy (a, "\021k\022l\023m\024n\025o\026p\027q\030r\031s\032t");
   if ((strcmp (a, "\x11k\x12l\x13m\x14n\x15o\x16p\x17q\x18r\x19s\x1At")) != 0)
       goto Fail;

   strcpy (a, "\033u\034v\035w\036x\037y\040z\041a\042b\043c\044d");
   if ((strcmp (a, "\x1bu\x1cv\x1dw\x1ex\x1fy z!a\"b#c$d")) != 0)
       goto Fail;

   strcpy (a, "\045e\046f\047g\050h\051i\052j\053k\054l\055m\056n\057o");
   if ((strcmp (a, "%e&f'g(h)i*j+k,l-m.n/o")) != 0)
       goto Fail;

   strcpy (a, "\060p\061q\062r\063s\064t\065u\066v\067w\070x\071y\072z");
   if ((strcmp (a, "0p1q2r3s4t5u6v7w8x9y:z")) != 0)
       goto Fail;

   strcpy (a, "\073A\074B\075C\076D\077E\100F\101G\102H\103I\104J");
   if ((strcmp (a, ";A<B=C>D?E@FAGBHCIDJ")) != 0)
       goto Fail;

   strcpy (a, "\105k\106l\107m\110n\111o\112p\113q\114r\115s");
   if ((strcmp (a, "EkFlGmHnIoJpKqLrMs")) != 0)
       goto Fail;

   strcpy (a, "\116t\117u\120v\121w\122x\123y\124z\125A\126B");
   if ((strcmp (a, "NtOuPvQwRxSyTzUAVB")) != 0)
       goto Fail;

   strcpy (a, "\127C\130D\131E\132F\133G\134H\135I\136J\137K");
   if ((strcmp (a, "WCXDYEZF[G\x5cH]I^J_K")) != 0)
       goto Fail;

   strcpy (a, "\140L\141M\142N\143O\144P\145Q\146R\147S\150T");
   if ((strcmp (a, "`LaMbNcOdPeQfRgShT")) != 0)
       goto Fail;

   strcpy (a, "\151U\152V\153W\154X\155Y\156Z\157A\160B\161C");
   if ((strcmp (a, "iUjVkWlXmYnZoApBqC")) != 0)
       goto Fail;

   strcpy (a, "\162D\163E\164F\165G\166H\167I\170J\171K\172L");
   if ((strcmp (a, "rDsEtFuGvHwIxJyKzL")) != 0)
       goto Fail;

   strcpy (a, "\173M\174N\175O\176P\177Q");
   if ((strcmp (a, "{M|N}O~P\x7fQ")) != 0)
       goto Fail;

   printf ("Passed Conformance Test 2.7.7.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.7.2\n");
  }
