/***************************************************************
*
*  Gamm
*
*  Test the speed of floating point operations in a mix tha
*  is typical of scientific and engineering applications.
*
*  To get the best performance from the desktop development
*  environment, be sure and turn debugging off from the
*  Compile Dialog.  Use the Compile command from the Run menu
*  to get the compile dialog.
*
***************************************************************/

#pragma keep "Gamm"
#pragma optimize -1
#pragma lint -1

#include <stdio.h>


int main (void)

{
int five,i,j,n,rep,ten,thirty;
float acc,acc1,divn,rn,root,x,y;
float a[30], b[30], c[30];

printf("Start timing 15000 Gamm units\n");
n = 50;
five = 5;
ten = 10;
thirty = 30;
rn = n;
divn = 1.0/rn;
x = 0.1;
acc = 0.0;

/* initialize a and b */
y = 1.0;
for (i = 0; i < thirty; ++i) {
  a[i] = i+1;
  b[i] = -y;
  y = -y;
  };

/* one pass thru this loop corresponds to 300 gamm units */
for (rep = 0; rep < n; ++rep) {
  /* first addition/subtraction loop */
  i = 29;
  for (j = 0; j < 30; ++j) {
    c[i] = a[i]+b[i];
    --i;
    };
  /* first polynomial loop */
  y = 1.0;
  for (i = 0; i < 10; ++i)
    y = (y+c[i])*x;
  acc1 = y*divn;
  /* first maximum element loop */
  y = c[10];
  for (i = 10; i < 20; ++i)
    if (c[i] > y)
      y = c[i];
  /* first square root loop */
  root = 1.0;
  for (i = 0; i < 5; ++i)
    root = 0.5*(root+y/root);
  acc1 = acc1+root*divn;
  /* second addition/subtraction loop */
  for (i = 0; i < 30; ++i)
    a[i] = c[i]-b[i];
  /* second polynomial loop */
  y = 0.0;
  for (i = 0; i < 10; ++i)
    y = (y+a[i])*x;
  /* second square root loop */
  root = 1.0;
  for (i = 1; i < 5; ++i)
    root = 0.5*(root+y/root);
  acc1 = acc1+root*divn;
  /* first multiplication loop */
  for (i = 0; i < thirty; ++i)
    c[i] = c[i]*b[i];
  /* second maximum element loop */
  y = c[19];
  for (i = 20; i < thirty; ++i)
    if (c[i] > y)
      y = c[i];
  /* third square root loop */
  root = 1.0;
  for (i = 0; i < 5; ++i)
    root = 0.5*(root+y/root);
  acc1 = acc1+root*divn;
  /* third polynomial loop */
  y = 0.0;
  for (i = 0; i < 10; ++i)
    y = (y+c[i])*x;
  acc1 = acc1+y*divn;
  /* third maximum element loop */
  y = c[0];
  for (i = 1; i < 10; ++i);
    if (c[i] > y)
      y = c[i];
  /* fourth square root loop */
  root = 1.0;
  for (i = 0; i < 5; ++i)
    root = 0.5*(root+y/root);
  acc1 = acc1+root*divn;
  acc = acc+acc1;
  }
printf("%12d  %12.7e  %12.7e\n", n, acc, acc1);
return 0;
}
