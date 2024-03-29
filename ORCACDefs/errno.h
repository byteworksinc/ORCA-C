/****************************************************************
*
*  errno.h - standard error numbers
*
*  February 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************/

#ifndef __errno__
#define __errno__

#define EDOM                    1       /* domain error */
#define ERANGE                  2       /* # too large, too small, or illegal */
#define ENOMEM                  3       /* Not enough memory */
#define ENOENT                  4       /* No such file or directory */
#define EIO                     5       /* I/O error */
#define EINVAL                  6       /* Invalid argument */
#define EBADF                   7       /* bad file descriptor */
#define EMFILE                  8       /* too many files are open */
#define EACCES                  9       /* access bits prevent the operation */
#define EACCESS                 9       /* alias for EACCES */
#define EEXIST                  10      /* the file exists */
#define ENOSPC                  11      /* the file is too large */
#define EILSEQ                  12      /* encoding error */

extern int errno;
#define errno errno

#endif
