*
*  This file builds the sample xcmd.cc.
*

*
*  There's nothing special about the compile -- just be sure the program
*  itself uses the xcmd pragma, the small memory model, and does not use the
*  segment directive.
*

compile xcmd.cc

*
*  The -x flag is crutial!  XCMDs must consist of a single segment, and
*  without the -x flag on the link, the linker creates an expressload
*  segment.
*

link -x xcmd keep=xcmd

*
*  The Rez compiler packs the executable code and a name into a file for
*  HyperCard.
*

compile xcmd.rez keep=Beep
