#include "lib/server.h"

int main(int argc, char** argv)
{

    init(argc, argv);

    struct sockaddr_in address;

    int socketfd, nsocket, valread;
    int addrlen = sizeof(address);

    char buffer[4096] = {0}; //? memset

    if ((socketfd = socket(AF_INET, SOCK_STREAM, 0)) == 0)
    {
        handle_error("Socket failed.");
        exit(0);
    }

    printf(YEL "\n[RULE] Type '/!stop' to stop the server\n" reset);

    printf(YEL "\n[RULE] Type '/!help' to get started\n" reset);

    printf("\n[SERVER] Listening ...  \n");

    while(true)
    {
        
    }
}