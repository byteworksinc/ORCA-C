/****************************************************************
*
*  stdio.h - input/output facilities
*
*  February 1989
*  Mike Westerfield
*
*  Copyright 1989, 1993, 1996
*  Byte Works, Inc.
*
****************************************************************/

#ifndef __stdio__
#define __stdio__

/*
 *  Misc.
 */

#ifndef __va_list__
#define __va_list__
typedef char *__va_list[2];
#endif

#ifndef EOF
#define EOF             (-1)
#endif

#ifndef NULL
#define NULL  (void *) 0L
#endif

#ifndef __size_t__
#define __size_t__ 1
typedef unsigned long size_t;
#endif

/* seek codes */

#define SEEK_SET        0
#define SEEK_CUR        1
#define SEEK_END        2

/*
 *  Error handling
 */

#ifndef __KeepNamespacePure__
   extern int sys_nerr;                    /* largest index for sys_errlist */
   extern char *sys_errlist[];             /* error messages */
#endif

/*
 *  files
 */

typedef struct __file {
   struct __file        *next;          /* next file in linked list */
   unsigned char        *_ptr,          /* next location to write to */
                        *_base,         /* first byte of the buffer */
                        *_end;          /* end of the file buffer */
   unsigned long        _size,          /* size of the file buffer */
                        _cnt;           /* # chars that can be read/written to buffer */
   int                  _pbk[2];        /* put back buffer */
   unsigned int         _flag,          /* buffer flags */
                        _file;          /* GS/OS file ID */
   } FILE;

#define BUFSIZ          1024            /* default buffer size */
#define _LBUFSIZ        255             /* line buffer size */

#define _IOFBF          0x0001          /* full buffering */
#define _IONBF          0x0002          /* no buffering */
#define _IOLBF          0x0004          /* flush when a \n is written */
#define _IOREAD         0x0008          /* currently reading */
#define _IOWRT          0x0010          /* currently writing */
#define _IORW           0x0020          /* read/write enabled */
#define _IOMYBUF        0x0040          /* buffer was allocated by stdio */
#define _IOEOF          0x0080          /* has an EOF been found? */
#define _IOERR          0x0100          /* has an error occurred? */
#define _IOTEXT         0x0200          /* is this file a text file? */
#define _IOTEMPFILE     0x0400          /* was this file created by tmpfile()? */
#define _IOAPPEND       0x0800          /* is this file open in append mode? */

extern FILE *stderr;                    /* standard I/O files */
extern FILE *stdin;
extern FILE *stdout;
#define stderr          stderr
#define stdin           stdin
#define stdout          stdout

#define L_tmpnam        26              /* size of a temp name */
#define TMP_MAX         10000           /* # of unique temp names */
#ifndef __KeepNamespacePure__
   #define SYS_OPEN        32767           /* max # open files */
#endif
#define FOPEN_MAX       32767           /* max # open files */
#define FILENAME_MAX    1024            /* recommended file name length */

/*
 *  Other types
 */

typedef long fpos_t;

/*
 *  Function declarations
 */

void            clearerr(FILE *);
int             fclose(FILE *);
int             feof(FILE *);
int             ferror(FILE *);
int             fflush(FILE *);
int             fgetc(FILE *);
int             fgetpos(FILE *, fpos_t *);
char           *fgets(char *, int, FILE *);
FILE           *fopen(const char *, const char *);
int             fprintf(FILE *, const char *, ...);
int             fputc(int, FILE *);
int             fputs(const char *, FILE *);
size_t          fread(void *, size_t, size_t, FILE *);
FILE           *freopen(const char *, const char *, FILE *);
int             fscanf(FILE *, const char *, ...);
int             fseek(FILE *, long, int);
int             fsetpos(FILE *, const fpos_t *);
long int        ftell(FILE *);
size_t          fwrite(const void *, size_t, size_t, FILE *);
int             getc(FILE *);
int             getchar(void);
char           *gets(char *);
void            perror(const char *);
int             printf(const char *, ...);
int             putc(int, FILE *);
int             putchar(int);
int             puts(const char *);
int             remove(const char *);
int             rename(const char *, const char *);
void            rewind(FILE *);
int             scanf(const char *, ...);
void            setbuf(FILE *, char *);
int             setvbuf(FILE *, char *, int, size_t);
int             sprintf(char *, const char *, ...);
int             snprintf(char *, size_t, const char *, ...);
int             sscanf(const char *, const char *, ...);
FILE           *tmpfile(void);
char           *tmpnam(char *);
int             ungetc(int c, FILE *);
int             vfprintf(FILE *, const char *, __va_list);
int             vfscanf(FILE *, const char *, __va_list);
int             vprintf(const char *, __va_list);
int             vscanf(const char *, __va_list);
int             vsprintf(char *, const char *, __va_list);
int             vsnprintf(char *, size_t, const char *, __va_list);
int             vsscanf(const char *, const char *, __va_list);

#endif
