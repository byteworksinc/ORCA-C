/************************************************
*
*  Artillery
*
*  This classic interactive text game lets you
*  pick the angle of your artillery gun in
*  an attempt to knock out the enemy position.
*  The computer picks a secret distance.  When
*  you fire, you will be told how much you
*  missed by, and must fire again.  The object
*  is to hit the target with the fewest shells.
*
************************************************/

#pragma keep "Artillery"
#pragma lint -1

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <misctool.h>

#define FALSE 0                 /* boolean constants */
#define TRUE  1

#define BLASTRADIUS 50.0        /* max distance from target for a hit */
#define DTR         0.01745329  /* convert from degrees to radians */
#define VELOCITY    434.6       /* muzzle velocity */

int main(void)

{
float angle,                    /* angle */
      distance,                 /* distance to the target */
      flightTime,               /* time of flight */
      x,                        /* distance to impact */
      vx,vy;                    /* x, y velocities */
int   done,                     /* is there a hit, yet? */
      tries,                    /* number of shots */
      i;                        /* loop variable */

/* choose a distance to the target */
srand((int) time(NULL));
for (i = 0; i < 100; ++i)
   rand();
distance = rand()/5.55373;

/* not done yet... */
done = FALSE;
tries = 1;

/* shoot 'til we hit it */
do {
   /* get the firing angle */
   printf("Firing angle: ");
   scanf("%f", &angle);

   /* compute the muzzle velocity in x, y */
   angle *= DTR;
   vx = cos(angle)*VELOCITY;
   vy = sin(angle)*VELOCITY;

   /* find the time of flight */
   /* (velocity = acceleration*flightTime, two trips) */
   flightTime = 2.0*vy/32.0;

   /* find the distance */
   /* (distance = velocity*flightTime) */
   x = vx*flightTime;

   /* see what happened... */
   if (fabs(distance-x) < BLASTRADIUS) {
      done = TRUE;
      printf("A hit, after %d", tries);
      if (tries == 1)
        printf(" try!\n");
      else
        printf(" tries!\n");
      switch (tries) {
         case 1:
            printf("(A lucky shot...)\n");
            break;
         case 2:
            printf("Phenomenal shooting!\n");
            break;
         case 3:
            printf("Good shooting.\n");
            break;
         otherwise:
            printf("Practice makes perfect - try again.\n");
         }
      }
   else if (distance > x)
      printf("You were short by %d feet.\n", (int)(distance-x));
   else
      printf("You were over by %d feet.\n", (int)(x-distance));
   ++tries;
   }
while (!done);
}
