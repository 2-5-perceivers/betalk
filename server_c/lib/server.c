#include "server.h"

void handle_error(char * arr)
{
    printf(RED);
    printf("\n[ERROR] ");
    while((*arr) != '\0')
	{
		printf("%c", *arr);
		arr++;
	}	
    printf(reset);
	printf("\n");
}

addr * addrall()
{
    addr * tr = (addr*)malloc(sizeof(addr));
    return tr;
}

void init(int argc, char ** argv)
{
    system("clear");

    printf(CYN "[SERVER] Server is starting ... \n\n" reset);

    addr * paddr = addrall();

    check_args(argc, argv, paddr);

    printf(CYN "[SERVER] Server started on ip %s, port %s\n", paddr->ip_adress, paddr->port ,reset);

}

bool check_digit(char c)
{
    if(c >= '0' && c <= '9')
        return true;
    else
        return false;
}

bool verify_ip_form(char * ip)
{
    short nrp = 0;
    bool digits = true;
    for(int i = 0; ip[i] != '\0'; i++)
    {
        if(ip[i] == '.')
            nrp++;
        else 
            if(check_digit(ip[i]) == false){
                digits = false;
                printf("%c is not a digit", ip[i]);
            }
    }
    if(nrp == 3 && digits == true)
        return true;
    else
        return false;
}

void check_args(int argc, char ** argv, addr * saddr)
{
    for(int i = 0; i < argc; i++)
    {
        int nr = 0;
        
        for(int j = 0; argv[i][j] != '\0'; j++)
        {
            nr++;
        }

        if(nr > 100)
        {
            handle_error("command to long.");
            exit(0);
        }
    }

    if(argc > 4)
    {
        handle_error("Too many arguments.");
        exit(0);
    }
    else
    {
        if(argc == 1)
        {
            handle_error("Select a command");
            exit(0);
        }
        else if(argc == 2)
        {
            if(strcmp(argv[1], "run") == 0)
            {
                //! run with default ip
                saddr->ip_adress = "127.0.0.1"; 
                saddr->port = "9090";
            }
            else
            {
                handle_error("Invalid command");
                printf("{%s} {%s}\n", argv[0], argv[1]);
                exit(0);
            }
        }
        else if(argc == 3)
        {
            if(strcmp(argv[1], "run") == 0)
            {
                bool f = verify_ip_form(argv[2]);
                if(f == true)
                {
                    //! run with given ip (argv[1])
                    saddr->ip_adress = argv[2]; 
                    saddr->port = "9090";
                }
                else
                {
                    handle_error("Invalid ip");
                    exit(0);
                }
            }
            else
            {
                handle_error("Invalid command");
                printf("{%s} {%s} {%s}\n", argv[0], argv[1], argv[2]);
                exit(0);
            }
        }
        else if(argc == 4)
        {
            if(strcmp(argv[1], "run") == 0)
            {
                bool f = verify_ip_form(argv[2]);
                if(f == true)
                {
                    //! run with given ip (argv[1])
                    saddr->ip_adress = argv[2]; 
                    saddr->port = argv[3];
                }
                else
                {
                    handle_error("Invalid ip");
                    exit(0);
                }
            }
            else
            {
                handle_error("Invalid command");
                printf("{%s} {%s} {%s} {%s}\n", argv[0], argv[1], argv[2], argv[3]);
                exit(0);
            }
        }
    }
}