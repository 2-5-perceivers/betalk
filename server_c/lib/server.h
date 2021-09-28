#ifndef SERVER_H
#define SERVER_H

#ifdef __cplusplus

extern "C"{

#endif

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <signal.h>
#include <stdlib.h>
#include <errno.h>
#include <stdarg.h>
#include <fcntl.h>
#include <netdb.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <string.h>
#include "../utils/colors.h"
#include <pthread.h>
#include <netinet/in.h>

#define MAXLINE 4096

typedef enum{
    true = 1,
    T = 1,
    t = 1,
    TRUE = 1,
    false = 0,
    F = 0,
    f = 0,
    FALSE = 0,
} bool;

typedef struct {
    char * ip_adress;
    char * port;
} addr;

void init(int argc, char ** argv);
void handle_error();
void check_args(int argc, char ** argv, addr * saddr);

#ifdef __cplusplus
}
#endif

#endif