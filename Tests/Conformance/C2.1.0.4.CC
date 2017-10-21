/* Conformance Test 2.1.0.4:  Verification of ANSI C trigraphs in */
/*                            character string constants          */

main ()
  {
   char a [] = "??=??/boh??'??!??-??(??<??)??>boy";

   if ((strcmp (a, "#\boh^|~[{]}boy")) != 0)
       goto Fail;

   printf ("Passed Conformance Test 2.1.0.4\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.1.0.4\n");
  }
