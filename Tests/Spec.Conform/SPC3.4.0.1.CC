/* Special Conformance Test 3.4.0.1:  Verification of #include command.       */
/*                                    First run the EXEC file spc3401.exec    */
/*                                                                            */
/* Other files needed:     cfile1                                             */
/*                         libfile2                                           */
/*                         ufile1                                             */
/*                         userfile2                                          */

#define    libFile(x)      <x>
#define    userFile(x)     x
#include   libFile(cfile1)
#include   userFile("ufile1")
#include   "userfile2"
#include   <libFile2>
