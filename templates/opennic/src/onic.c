#include <stdio.h>
#include <stdlib.h>
#include "onic.h"

void ping(const char *onic_name, const char *remote_server_name, int num_pings) {
    char command[256];
    
    // Construct the command string
    snprintf(command, sizeof(command), "ping -I %s -c %d %s", onic_name, num_pings, remote_server_name);
    
    // Print the command for debugging purposes (optional)
    printf("Executing command: %s\n", command);
    
    // Run the command
    int result = system(command);
    
    // Check the result (optional)
    if (result != 0) {
        printf("Ping command failed with exit code %d\n", result);
    }
}

