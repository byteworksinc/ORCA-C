*
*  This file builds the sample nba.cc.
*

*
*  There's nothing special about the compile -- just be sure the program
*  itself uses the nba pragma, the small memory model, and does not use the
*  segment directive.
*

compile nba.cc

*
*  The -x flag is crutial!  NBAs must consist of a single segment, and
*  without the -x flag on the link, the linker creates an expressload
*  segment.
*

link -x nba keep=nba

*
*  The Rez compiler packs the executable code and a name into a file for
*  HyperStudio.
*

compile nba.rez keep=Beep
filetype Beep $BC $4007
