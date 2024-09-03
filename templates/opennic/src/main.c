#include <stdio.h>
#include <stdlib.h>
#include "onic.h"

#define NUM_PINGS 10  // Define NUM_PINGS in main.c

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <onic_name> <remote_server_name>\n", argv[0]);
        return 1;
    }

    const char *onic_name = argv[1];  // Get the network interface name from the command-line argument
    const char *remote_server_name = argv[2];  // Get the remote server name from the command-line argument

    ping(onic_name, remote_server_name, NUM_PINGS);
    
    return 0;
}

