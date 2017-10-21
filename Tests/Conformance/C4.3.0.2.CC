/* Conformance Test 4.3.0.2:  Check uniqueness of static variables       */

static int var;

int sub1(void)

{
static int var;

var = 2;

   {
   static int var;

   var = 3;
   if (var != 3)
      return 1;
   }

if (var != 2)
   return 1;
return 0;
}


int sub2(void)

{
static int var;

var = 2;

   {
   static int var;

   var = 3;
   if (var != 3)
      return 1;
   }

if (var != 2)
   return 1;
return 0;
}


void main (void)

{
var = 1;

if (sub1()) goto Fail;
if (sub2()) goto Fail;
if (var != 1) goto Fail;

printf ("Passed Conformance Test 4.3.0.2\n");
return;

Fail: printf ("Failed Conformance Test 4.3.0.2\n");
}
