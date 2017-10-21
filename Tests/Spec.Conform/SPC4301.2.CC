/* The second separately compiled file for Special Conformance Test 4.3.0.1 */
/* Function ChangeChar and variable real are accessed by main.              */

float real;

void ChangeChar (char *ch)
  {
   *ch += 1;
  }
