****************************************************************
*
*  This file contains constant values defined in the C interfaces
*  that are also used in the assembly language portion of the
*  libraries.
*
****************************************************************
;
;  error numbers
;
EDOM     gequ  1                        domain error
ERANGE   gequ  2                        # too large, too small, or illegal
ENOMEM   gequ  3                        Not enough memory
ENOENT   gequ  4                        No such file or directory
EIO      gequ  5                        I/O error
EINVAL   gequ  6                        Invalid argument
EBADF    gequ  7                        bad file descriptor
EMFILE   gequ  8                        too many files are open
EACCES   gequ  9                        access bits prevent the operation
EEXIST   gequ  10                       the file exists
ENOSPC   gequ  11                       the file is too large
;
;  masks for the __ctype array
;
_digit   gequ  $01                      ['0'..'9']
_upper   gequ  $02                      ['A'..'Z']
_lower   gequ  $04                      ['a'..'z']
_control gequ  $08                      [chr(0)..chr(31),chr(127)]
_punctuation gequ $10                   [' ','!'..'/',':'..'@','['..'`','{'..'~']
_space   gequ  $20                      [chr(9)..chr(13),' ']
_hex     gequ  $40                      ['0'..'9','a'..'f','A'..'F']
_print   gequ  $80                      [' '..'~']
;
;  masks for the __ctype2 array
;
_csym    gequ  $01                      ['0'..'9','A'..'Z','a'..'z','_']
_csymf   gequ  $02                      ['A'..'Z','a'..'z'.'_']
_octal   gequ  $04                      ['0'..'7']
;
;  signal numbers
;
SIGABRT  gequ  1
SIGFPE   gequ  2
SIGILL   gequ  3
SIGINT   gequ  4
SIGSEGV  gequ  5
SIGTERM  gequ  6
;
;  The FILE record
;
!                                       flags
!                                       -----
_IOFBF   gequ  $0001                    full buffering
_IONBF   gequ  $0002                    no buffering
_IOLBF   gequ  $0004                    flush when a \n is written
_IOREAD  gequ  $0008                    currently reading
_IOWRT   gequ  $0010                    currently writing
_IORW    gequ  $0020                    read/write enabled
_IOMYBUF gequ  $0040                    buffer was allocated by stdio
_IOEOF   gequ  $0080                    has an EOF been found?
_IOERR   gequ  $0100                    has an error occurred?
_IOTEXT  gequ  $0200                    is this file a text file?
_IOTEMPFILE gequ $0400	was this file created by tmpfile()?

!                                       record structure
!                                       ----------------
FILE_next gequ 0                        disp to next pointer (must stay 0!)
FILE_ptr  gequ FILE_next+4              next location to write to
FILE_base gequ FILE_ptr+4               first byte of the buffer
FILE_end  gequ FILE_base+4              end of the file buffer
FILE_size gequ FILE_end+4               size of the file buffer
FILE_cnt  gequ FILE_size+4              # chars that can be read/writen to buffer
FILE_pbk  gequ FILE_cnt+4               put back character
FILE_flag gequ FILE_pbk+4               buffer flags
FILE_file gequ FILE_flag+2              GS/OS file ID

sizeofFILE gequ FILE_file+2             size of the record

BUFSIZ   gequ  1024                     default file buffer size
_LBUFSIZ gequ  255                      line buffer size

L_tmpnam gequ  9                        size of a temp name
TMP_MAX  gequ  10000                    # of uniq temp names
;
;  Seek codes for fseek
;
SEEK_SET gequ  0                        seek from start of file
SEEK_CUR gequ  1                        seek from current position
SEEK_END gequ  2                        seek from end of file
;
;  Values for fcntl.h
;
OPEN_MAX gequ  30                       files in the file array

F_DUPFD  gequ  1                        dup file flag (fcntl)

O_RDONLY gequ  $0001                    file is read only
O_WRONLY gequ  $0002                    file is write only
O_RDWR   gequ  $0004                    file is read/write
O_NDELAY gequ  $0008                    not used
O_APPEND gequ  $0010                    append to file on all writes
O_CREAT  gequ  $0020                    create a new file if needed
O_TRUNC  gequ  $0040                    erase old file
O_EXCL   gequ  $0080                    don't create a new file
O_BINARY gequ  $0100                    file is binary
;
;  Misc.
;
EOF      gequ  -1                       end of file character

stdinID  gequ  -1                       standard in file ID
stdoutID gequ  -2                       standard out file ID
stderrID gequ  -3                       error out file ID
