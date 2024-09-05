#include <stdio.h>
#include <stdlib.h>
#include "onic.h"

int main(int argc, char *argv[]) {
    char *onic_name = NULL;
    char *remote_server_name = NULL;
    int index = 0;

    // Example: Get the first IP (port 1) for device 1
    char *device_ip = get_network(1, 1);
    if (device_ip != NULL) {
        printf("Device IP (port 1): %s\n", device_ip);
    } else {
        printf("Failed to retrieve device IP for port 1.\n");
    }

    // Example: Get the second IP (port 2) for device 1
    char *device_ip2 = get_network(1, 2);
    if (device_ip2 != NULL) {
        printf("Device IP (port 2): %s\n", device_ip2);
    } else {
        printf("Failed to retrieve device IP for port 2.\n");
    }

    // Check flags and assign values
    flags_check(argc, argv, &onic_name, &remote_server_name, &index);

    // Continue with the rest of your program logic using onic_name, remote_server_name, and index
    int num_pings = read_parameter(index, "NUM_PINGS");
    if (num_pings == -1) {
        return 1;
    }

    ping(onic_name, remote_server_name, num_pings);

    return 0;
}