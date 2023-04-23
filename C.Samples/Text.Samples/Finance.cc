/************************************************
*
*  Finance
*
*  This program prints the balance on an
*  account for monthly payments, along with the
*  total amount paid so far.
*
*************************************************/

#pragma keep "Finance"
#pragma lint -1

#include <stdio.h>

#define LOANAMOUNT 10000.0       /* amount of the loan */
#define PAYMENT    600.0         /* monthly payment */
#define INTEREST   15            /* yearly interest (as %) */

int main(void)

{
float balance,                   /* amount left to pay */
      monthlyInterest,           /* multiplier for interest */
      paid ;                     /* total amount paid */
int   month;                     /* month number */

/* set up the initial values */
balance = LOANAMOUNT;
paid = month = 0;
monthlyInterest = 1.0 + INTEREST/1200.0;

/* write out the conditions */
printf("Payment schedule for a loan of %10.2f\n", LOANAMOUNT);
printf("with monthly payments of %5.2f at an\n", PAYMENT);
printf("interest rate of %d%%.\n\n", INTEREST);
printf("          month        balance    amount paid\n");
printf("          -----        -------    -----------\n");

/* check for payments that are too small */
if (balance*monthlyInterest - balance >= PAYMENT)
   printf("The payment is too small!");
else
   while (balance > 0) {
      /* add in the interest */
      balance *= monthlyInterest;
      /* make a payment */
      if (balance > PAYMENT) {
         balance -= PAYMENT;
         paid += PAYMENT;
         }
      else {
         paid += balance;
         balance = 0;
         }
      /* update the month number */
      ++month;
      /* write the new statistics */
      printf("%15d %14.2f %14.2f\n", month, balance, paid);
      }
}
