/* Conformance Test 20.1.0.1:  Verification of clock library function */

#include   <time.h>
#include   <orca.h>
#include   <adb.h>
#include   <event.h>
#include   <locator.h>
#include   <memory.h>
#include   <misctool.h>
#include   <desk.h>
#include   <quickdraw.h>

main ()
  {
   clock_t clicks;
   char    **dpHandle, *dPageAddr;
   int     myID;

   struct TSInfo    { int toolSet;                 /* Tool Locator table to  */
                      int minVersion; };           /*   load RAM-based tools */
   struct ToolTable { int count;
                      struct TSInfo tsInfo [2]; } toolTbl;


   /* In order to use the clock function, must ensure that Event Manager      */
   /* has been started.  The Event Manager requires the Miscellaneous Toolset */
   /* QuickDraw II, the Desk Manager, and the ADB Toolset.  First allocate    */
   /* 4 pages of direct page workspace for the Event Manager and QD II.       */

   myID     = userid ();
   dpHandle = NewHandle (1024L, myID, 0xC015, 0x00000000L);
   if ( toolerror () )
       goto Fail1;
   if (dpHandle == NULL)
       goto Fail1;
   dPageAddr = *dpHandle;

   if (! (MTStatus ()) )               /* start the Miscellaneous Toolset */
       MTStartUp ();

   if (! (QDStatus ()) )                            /* start QuickDraw II */
     {
       QDStartUp ((int) dPageAddr, 0, 0, myID);
       if ( toolerror () )
           goto Fail2;
     }

   if (! (EMStatus ()) )                           /* start Event Manager */
     {
       EMStartUp (((int) dPageAddr) + 768, 0, 0, 640, 0, 200, myID);
       if ( toolerror () )
           goto Fail3;
     }

   toolTbl.count = 2;                        /* load Desk Mgr & ADB tools */
   toolTbl.tsInfo [0].toolSet    = 5;
   toolTbl.tsInfo [1].toolSet    = 9;
   toolTbl.tsInfo [0].minVersion = toolTbl.tsInfo [1].minVersion = 1;

   LoadTools ((void *) (&toolTbl));
   if ( toolerror () )
       goto Fail4;

   if (! (DeskStatus ()) )                      /* start the Desk Manager */
       DeskStartUp ();

   if (! (ADBStatus ()) )                  /* start the Apple Desktop Bus */
       ADBStartUp ();


   /* Finally, can call clock. */

   clicks = clock ();


   /* Shut down the tools in the reverse order of start up. */

   ADBShutDown ();
   DeskShutDown ();
   EMShutDown ();
   QDShutDown ();
   MTShutDown ();

   printf ("Passed Conformance Test 20.1.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 20.1.0.1\n");

Fail1:
   printf ("Unable to allocate direct page for Conformance Test 20.1.0.1\n");

Fail2:
   printf ("Unable to start QuickDraw II for Conformance Test 20.1.0.1\n");

Fail3:
   printf ("Unable to start Event Manager for Conformance Test 20.1.0.1\n");

Fail4:
   printf ("Unable to load RAM tools for Conformance Test 20.1.0.1\n");
  }
