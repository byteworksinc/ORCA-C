/* Deviance Test 3.4.0.1:  Ensure errors flagged for invalid #include commands */

int printf(const char *, ...);

#define    BadMacro(x)                 <x
#include   BadMacro(string.h
#define    BadMacro2(x)                x
#include   BadMacro2(d3401.data")
#include   "d3401.data>
#include   <d3401.data"
#include   d3401.data
#include   "d3401.data
#include   d3401.data"
#include   <d3401.data
#include   d3401.data>
#include   "nosuchfile"

int main (void)
  {
   printf ("Failed Deviance Test 3.4.0.1\n");
  }
