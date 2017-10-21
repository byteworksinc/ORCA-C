/* Conformance Test 17.5.0.2:  Verification of fseek, rewind, and ftell */
/*                             functions for text files                 */

#include <stdio.h>

main ()
  {
   FILE *f1;                           /* file pointer */
   int i, j, m;
   long L1;
   char s  [254], ch1;
   char ch [254] = "a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z."
                   "a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z."
                   "a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z."
                   "a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z."
                   "A.B.C.D.E.F.G.H.I.J.K.L.M.N.O.P.Q.R.S.T.U.V.";


   f1 = fopen ("14:tmp", "w+");         /* create temporary file to work on */
   if (f1 == NULL)
       goto Fail1;
   for (i = 0; i < 100; i++)           /* write 100 lines to the file */
     {
       j = fprintf (f1, "%s\n", ch);
       if (j == EOF)
           goto Fail2;
     }

   /* Test seek from beginning of file. */

   j = fseek (f1, 0L, SEEK_SET);
   if (j)
       goto Fail;
   for (i = 0; i < 100; i++) {
       j = fscanf (f1, "%s", s);
       if (j == EOF)
           goto Fail3;
       if (strcmp (s, ch))
           goto Fail;
       }

   /* Test seek from end of file. */

   j = fseek (f1, 0L, SEEK_END);
   if (j)
       goto Fail;
   j = fscanf (f1, "%c", &m);
   if (j != EOF)
       goto Fail3;

   /* Test ftell function. */

   L1 = ftell (f1);
   if (L1 != 25300)
       goto Fail;
   rewind (f1);
   L1 = ftell (f1);
   if (L1 != 0)
       goto Fail;
       
   ch1 = fgetc (f1);
   if (ch1 == EOF)
       goto Fail3;
   if (ch1 != 'a')
       goto Fail;

   ch1 = fgetc (f1);
   if (ch1 == EOF)
       goto Fail3;
   if (ch1 != '.')
       goto Fail;
       
   L1 = ftell (f1);
   if (L1 != 2)
       goto Fail;

   ch1 = fgetc (f1);
   if (ch1 == EOF)
       goto Fail3;
   if (ch1 != 'b')
       goto Fail;

   ch1 = fgetc (f1);
   if (ch1 == EOF)
       goto Fail3;
   if (ch1 != '.')
       goto Fail;

   ch1 = fgetc (f1);
   if (ch1 == EOF)
       goto Fail3;
   if (ch1 != 'c')
       goto Fail;

   j = fseek (f1, L1, SEEK_SET);       /* verify that ftell-position works */
   if (j)
       goto Fail;
   ch1 = fgetc (f1);
   if (ch1 == EOF)
       goto Fail3;
   if (ch1 != 'b')
       goto Fail;

   /* Close the file and quit. */

   j = fclose (f1);
   if (j == EOF)
       goto Fail4;

   printf ("Passed Conformance Test 17.5.0.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.5.0.2\n");
   return;

Fail1:
   printf ("Could not open tmp file for Conformance Test 17.5.0.2\n");
   return;

Fail2:
   printf ("Could not write to file for Conformance Test 17.5.0.2\n");
   return;

Fail3:
   printf ("Error while reading file for Conformance Test 17.5.0.2\n");
   return;

Fail4:
   printf ("Could not close file for Conformance Test 17.5.0.2\n");
   return;
  }
