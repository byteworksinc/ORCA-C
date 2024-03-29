/****************************************************************
*
*  time.h - time and date functions
*
*  February 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************/

#ifndef __time__
#define __time__

typedef unsigned long clock_t;
typedef unsigned long time_t;

struct tm {
        int tm_sec;
        int tm_min;
        int tm_hour;
        int tm_mday;
        int tm_mon;
        int tm_year;
        int tm_wday;
        int tm_yday;
        int tm_isdst;
        };

#ifndef __struct_timespec__
#define __struct_timespec__
struct timespec {
        time_t tv_sec;
        long   tv_nsec;
        };
#endif

clock_t         __clocks_per_sec(void);
#ifndef __KeepNamespacePure__
   #define CLK_TCK      (__clocks_per_sec())
#endif
#define CLOCKS_PER_SEC  (__clocks_per_sec())

#define TIME_UTC 1

#ifndef NULL
#define NULL  (void *) 0L
#endif

#ifndef __size_t__
#define __size_t__ 1
typedef unsigned long size_t;
#endif

extern int      __useTimeTool;

char           *asctime(const struct tm *);
clock_t         clock(void);
char           *ctime(const time_t *);
double          difftime(time_t, time_t);
struct tm      *gmtime(const time_t *);
struct tm      *localtime(const time_t *);
time_t          mktime(struct tm *);
size_t          strftime(char *, size_t, const char *, const struct tm *);
time_t          time(time_t *);
int             timespec_get(struct timespec *, int);

#endif
