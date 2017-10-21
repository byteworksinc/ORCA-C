/* Conformance Test 4.6.4.2:  Verify that subscripts work        */
/*                            properly in initializers.          */

#include <stdio.h>
#include <string.h>

char str1[] = "Hello, ";
char str2[] = "*world.";

char *str[] = {&str1[0], &str2[1]};

int tensor[3][3][3] = {0,1,2,3,4,5,6,7,8,
                       9,10,11,12,13,14,15,16,17,
                       18,19,20,21,22,23,24,25,26};

int *ip[27] = {
               &tensor[0][0][0],
               &tensor[0][0][1],
               &tensor[0][0][2],
               &tensor[0][1][0],
               &tensor[0][1][1],
               &tensor[0][1][2],
               &tensor[0][2][0],
               &tensor[0][2][1],
               &tensor[0][2][2],
               &tensor[1][0][0],
               &tensor[1][0][1],
               &tensor[1][0][2],
               &tensor[1][1][0],
               &tensor[1][1][1],
               &tensor[1][1][2],
               &tensor[1][2][0],
               &tensor[1][2][1],
               &tensor[1][2][2],
               &tensor[2][0][0],
               &tensor[2][0][1],
               &tensor[2][0][2],
               &tensor[2][1][0],
               &tensor[2][1][1],
               &tensor[2][1][2],
               &tensor[2][2][0],
               &tensor[2][2][1],
               &tensor[2][2][2]
               };

main()

{
int i;
char st1[20],st2[20];
int fail = 0;

strcpy(st1, str[0]);
strcat(st1, str[1]);
strcpy(st2, &str1[0]);
strcat(st2, &str2[1]);
if (strcmp(st1,st2) != 0)
   fail = 1;

for (i = 0; i < 27; ++i)
   if (*ip[i] != i)
      fail = 1;

if (fail)
   printf ("Failed Conformance Test 4.6.4.3\n");
else
   printf ("Passed Conformance Test 4.6.4.3\n");
}
