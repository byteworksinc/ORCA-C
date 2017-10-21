/* Conformance Test 2.6.0.1:  Check if reserved words can be used as  */
/*                            preprocessor macro names.  All reserved */
/*                            words except GOTO, IF, and RETURN are   */
/*                            checked.  (They're used in the program) */

#define    asm         1
#define    auto        2
#define    break       3
#define    case        4
#define    char        5
#define    comp        6
#define    const       7
#define    continue    8
#define    default     9
#define    do          10
#define    double      11
#define    else        12
#define    enum        13
#define    extended    14
#define    extern      15
#define    float       16
#define    for         17
#define    inline      18
#define    int         19
#define    long        20
#define    pascal      21
#define    register    22
#define    segment     23
#define    short       24
#define    signed      25
#define    sizeof      26
#define    static      27
#define    struct      28
#define    switch      29
#define    typedef     30
#define    union       31
#define    unsigned    32
#define    void        33
#define    volatile    34
#define    while       35

main ()
  {
   if (asm         != 1)
       goto Fail;
   if (auto        != 2)
       goto Fail;
   if (break       != 3)
       goto Fail;
   if (case        != 4)
       goto Fail;
   if (char        != 5)
       goto Fail;
   if (comp        != 6)
       goto Fail;
   if (const       != 7)
       goto Fail;
   if (continue    != 8)
       goto Fail;
   if (default     != 9)
       goto Fail;
   if (do          != 10)
       goto Fail;
   if (double      != 11)
       goto Fail;
   if (else        != 12)
       goto Fail;
   if (enum        != 13)
       goto Fail;
   if (extended    != 14)
       goto Fail;
   if (extern      != 15)
       goto Fail;
   if (float       != 16)
       goto Fail;
   if (for         != 17)
       goto Fail;
   if (inline      != 18)
       goto Fail;
   if (int         != 19)
       goto Fail;
   if (long        != 20)
       goto Fail;
   if (pascal      != 21)
       goto Fail;
   if (register    != 22)
       goto Fail;
   if (segment     != 23)
       goto Fail;
   if (short       != 24)
       goto Fail;
   if (signed      != 25)
       goto Fail;
   if (sizeof      != 26)
       goto Fail;
   if (static      != 27)
       goto Fail;
   if (struct      != 28)
       goto Fail;
   if (switch      != 29)
       goto Fail;
   if (typedef     != 30)
       goto Fail;
   if (union       != 31)
       goto Fail;
   if (unsigned    != 32)
       goto Fail;
   if (void        != 33)
       goto Fail;
   if (volatile    != 34)
       goto Fail;
   if (while       != 35)
       goto Fail;

   printf ("Passed Conformance Test 2.6.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.6.0.1\n");
  }
