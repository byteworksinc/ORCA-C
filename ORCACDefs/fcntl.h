/****************************************************************
*
*  fcntl.h - UNIX primitive input/output facilities
*
*  October 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************/

#ifndef __fcntl__
#define __fcntl__

#define OPEN_MAX        30

#define F_DUPFD         1

#define O_RDONLY        0x0001
#define O_WRONLY        0x0002
#define O_RDWR          0x0004
#define O_NDELAY        0x0008
#define O_APPEND        0x0010
#define O_CREAT         0x0020
#define O_TRUNC         0x0040
#define O_EXCL          0x0080
#define O_BINARY        0x0100

int             chmod(const char *, int);
int             close(int);
int             creat(const char *, int);
int             dup(int);
int             fcntl(int, int, ...);
long            lseek(int, long, int);
int             open(const char *, int, ...);
int             read(int, void *, unsigned);
int             write(int, const void *, unsigned);

#endif
