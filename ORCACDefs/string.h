/****************************************************************
*
*  string.h - string processing
*
*  February 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************/

#ifndef __string__
#define __string__

#ifndef __size_t__
#define __size_t__ 1
typedef unsigned long size_t;
#endif

#ifndef NULL
#define NULL  (void *) 0L
#endif

#ifndef __KeepNamespacePure__
   char        *c2pstr(const char *);
#endif
void           *memchr(const void *, int, size_t);
int             memcmp(const void *, const void *, size_t);
void           *memcpy(void *, const void *, size_t);
void           *memmove(void *, const void *, size_t);
void           *memset(void *, int, size_t);
#ifndef __KeepNamespacePure__
   char        *p2cstr(const char *);
#endif
char           *strcat(char *, const char *);
char           *strchr(const char *, int);
int             strcmp(const char *, const char *);
int             strcoll(const char *, const char *);
char           *strcpy(char *, const char *);
size_t          strcspn(const char *, const char *);
char           *strerror(int);
size_t          strlen(const char *);
char           *strncat(char *, const char *, size_t);
int             strncmp(const char *, const char *, size_t);
char           *strncpy(char *, const char *, size_t);
char           *strpbrk(const char *, const char *);
#ifndef __KeepNamespacePure__
   int          strpos(char *, char);
#endif
char           *strrchr(const char *, int);
#ifndef __KeepNamespacePure__
   char        *strrpbrk(char *, char *);
   int          strrpos(char *, char);
#endif
size_t          strspn(const char *, const char *);
char           *strstr(const char *, const char *);
char           *strtok(char *, const char *);
size_t          strxfrm(char *, const char *, size_t);


#endif
